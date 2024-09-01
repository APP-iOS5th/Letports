//
//  ProfileEditVM.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//

import Combine
import UIKit
import Kingfisher

enum ProfileEditCellType {
    case profileImage
    case nickName
    case simpleInfo
}

class ProfileEditVM {
    @Published var user: LetportsUser?
    @Published var selectedImage: UIImage?
    @Published private(set) var usernickName: String?
    @Published private(set) var userSimpleInfo: String?
    @Published private(set) var isUpdate: Bool = false
    @Published private(set) var isFormValid: Bool = false
    
    let maxNickNameCount = 16
    let maxSimpleInfoCount = 20
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: ProfileEditCoordinatorDelegate?
    
    private var cellType: [ProfileEditCellType] {
        var cellTypes: [ProfileEditCellType] = []
        cellTypes.append(.profileImage)
        cellTypes.append(.nickName)
        cellTypes.append(.simpleInfo)
        return cellTypes
    }
    
    init(user: LetportsUser?) {
        self.user = user
        self.usernickName = user?.nickname ?? ""
        self.userSimpleInfo = user?.simpleInfo ?? ""
        self.loadImage(urlString: user?.image ?? "")
        setupValidation()
    }
    
    func getCellTypes() -> [ProfileEditCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func editUserNickName(content: String) {
        self.usernickName = content
    }
    
    func editUserSimpleInfo(content: String) {
        self.userSimpleInfo = content
    }
    
    func changeSelectedImage(selectedImage: UIImage) {
        self.selectedImage = selectedImage
    }
    
    func backToProfile() {
        self.delegate?.dismissOrPopViewController()
    }
    
    func photoUploadBtnDidTap() {
        self.delegate?.presentImagePickerController()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest($usernickName, $userSimpleInfo)
            .map { [weak self] nickname, simpleInfo in
                guard let self = self else { return false }
                
                guard let nickname = nickname, let simpleInfo = simpleInfo else {
                    return false
                }
                
                let isNicknameValid = nickname.count != 0 && nickname.count <= maxNickNameCount
                let isSimpleInfoValid = simpleInfo.count != 0 && simpleInfo.count <= maxSimpleInfoCount
                
                return isNicknameValid && isSimpleInfoValid
            }
            .assign(to: &$isFormValid)
    }
    
    func profileUpdate() -> AnyPublisher<Void, Never> {
        guard !isUpdate else {
            return Just(()).eraseToAnyPublisher()
        }
        isUpdate = true
        
        return uploadImage()
            .flatMap { [weak self] imageUrl -> AnyPublisher<Void, Never> in
                guard let self = self else {
                    return Just(()).eraseToAnyPublisher()
                }
                return self.editProfile(imageUrl: imageUrl ?? "")
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isUpdate = false
            })
            .eraseToAnyPublisher()
    }
    
    private func uploadImage() -> AnyPublisher<String?, Never> {
        guard let image = selectedImage else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        let filePath: StorageFilePath
        
        if let existingImageUrl = user?.image, !existingImageUrl.isEmpty {
            if existingImageUrl.hasPrefix("gs://") {
                let storagePath = existingImageUrl.replacingOccurrences(of: "gs://letports-81f7f.appspot.com/", with: "")
                filePath = .specificPath(storagePath)
            } else if let url = URL(string: existingImageUrl), url.host == "firebasestorage.googleapis.com" {
                let path = url.path.replacingOccurrences(of: "/v0/b/letports-81f7f.appspot.com/o/", with: "")
                if let decodedPath = path.removingPercentEncoding {
                    filePath = .specificPath(decodedPath)
                } else {
                    filePath = .userProfileImageUpload
                }
            } else {
                filePath = .userProfileImageUpload
            }
        } else {
            filePath = .userProfileImageUpload
        }
        
        return FirebaseStorageManager.uploadSingleImages(image: image, filePath: filePath)
            .map { url in
                url.absoluteString
            }
            .catch { error -> Just<String?> in
                print("Failed to upload image: \(error.localizedDescription)")
                return Just(nil)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func editProfile(imageUrl: String) -> AnyPublisher<Void, Never> {
        guard let user = user?.uid else {
            return Just(()).eraseToAnyPublisher()
        }
        
        let userCollectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(user)
        ]
        
        let updatedFields: [String: Any] = [
            "Image": imageUrl,
            "SimpleInfo": userSimpleInfo as Any,
            "NickName": usernickName as Any
        ]
        
        return FM.updateData(pathComponents: userCollectionPath, fields: updatedFields)
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
    
    private func loadImage(urlString: String) {
        guard selectedImage == nil else { return }
        guard let url = URL(string: urlString) else { return }
        
        let resource = KF.ImageResource(downloadURL: url)
        KingfisherManager.shared.retrieveImage(with: resource) { [weak self] result in
            switch result {
            case .success(let value):
                self?.selectedImage = value.image
            case .failure(let error):
                print("Failed to load image: \(error.localizedDescription)")
                self?.selectedImage = nil
            }
        }
    }
    
}
