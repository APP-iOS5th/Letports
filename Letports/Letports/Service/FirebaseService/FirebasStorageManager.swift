//
//  FirebasStorageManager.swift
//  Letports
//
//  Created by Chung Wussup on 8/19/24.
//

import UIKit
import Firebase
import FirebaseStorage
import Combine

enum FirebaseStorageError: Error {
    case imageDataConversionFailed
    case uploadFailed(error: Error)
    case downloadURLFailed(error: Error)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .imageDataConversionFailed:
            return "이미지를 데이터로 변환하지 못했어요."
        case .uploadFailed(let error):
            return "이미지 업로드 실패: \(error.localizedDescription)"
        case .downloadURLFailed(let error):
            return "다운로드 URL을 찾지 못했어요: \(error.localizedDescription)"
        case .unknown:
            return "알 수 없는 오류 발생."
        }
    }
}


enum StorageFilePath {
    /// 모임 이미지 경로
    case gatherImageUpload
    /// 게시글 이미지 경로
    case boardImageUpload
    /// 유저 프로필 이미지 경로
    case userProfileImageUpload
    
    case specificPath(String)
    
    var pathStr: String {
        switch self {
        case .boardImageUpload:
            return "Board_Upload_Images/"
        case .gatherImageUpload:
            return "Gather_Upload_Images/"
        case .userProfileImageUpload:
            return "User_Profile_Upload_Images/"
        case .specificPath(let path):
            return path
        }
    }

}

class FirebaseStorageManager {
    
    static func deleteImage(filePath: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let storageRef = Storage.storage().reference(withPath: filePath)
            storageRef.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    static func uploadImages(images: [UIImage],
                             filePath: StorageFilePath) -> AnyPublisher<[URL], FirebaseStorageError> {
        //images 배열에 5개만 map을 통해 uploadSingleImage 함수 실행
        //최대 이미지 개수를 5개로 제한할 것이지만 혹시 모를 상황에 대비하기 위해 prefix사용
        let uploadPublishers = images.prefix(5).map { image in
            uploadSingleImage(image: image, filePath: filePath)
        }
        
        return Publishers.MergeMany(uploadPublishers)
            .collect() // URL 배열로 합침
            .mapError { error -> FirebaseStorageError in
                return .uploadFailed(error: error)
            }
            .eraseToAnyPublisher()
    }
    
    static func uploadSingleImage(image: UIImage,
                            filePath: StorageFilePath) -> AnyPublisher<URL, FirebaseStorageError> {
        return Future { promise in
            guard let imageData = image.jpegData(compressionQuality: 0.4) else {
                promise(.failure(.imageDataConversionFailed))
                return
            }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let fullPath: String
            switch filePath {
            case .specificPath(let existingPath):
                fullPath = existingPath
            default:
                let imageName = UUID().uuidString + String(Date().timeIntervalSince1970)
                fullPath = filePath.pathStr + imageName
            }
            
            let firebaseRef = Storage.storage().reference().child(fullPath)
            
          
            firebaseRef.putData(imageData, metadata: metaData) { _, error in
                if let error = error {
                    promise(.failure(.uploadFailed(error: error)))
                    return
                }
                
                firebaseRef.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(.downloadURLFailed(error: error)))
                    } else if let url = url {
                        promise(.success(url))
                    } else {
                        promise(.failure(.unknown))
                    }
                }
            }
        }
        .retry(3) // 업로드 실패 시 3번까지 재시도
        .eraseToAnyPublisher()
    }
}
