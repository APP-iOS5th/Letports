//
//  FirestoreManager.swift
//  Letports
//
//  Created by Chung Wussup on 8/19/24.
//

import FirebaseFirestore
import Combine


enum FirestoreError: LocalizedError {
    case documentNotFound
    case dataEncodingFailed
    case dataDecodingFailed
    case updateFailed
    case deleteFailed
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Firestore에서 Document를 찾을 수 없어요."
        case .dataEncodingFailed:
            return "Firestore의 데이터를 인코딩하지 못했어요."
        case .dataDecodingFailed:
            return "Firestored에서 데이터를 디코딩하지 못했어요."
        case .updateFailed:
            return "Firestore에서 Document를 업데이트하지 못했어요."
        case .deleteFailed:
            return "Firestore에서 Document를 삭제하지 못했어요."
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

class FirestoreManager {
    static let shared = FirestoreManager()
    
    private init() {}
    
    //CREATE
    func setData<T: Encodable>(collection: String, 
                               document: String,
                               data: T) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            do {
                let encodedData = try Firestore.Encoder().encode(data)
                FIRESTORE.collection(collection).document(document).setData(encodedData) { error in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(.dataEncodingFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    //READ
    func getData<T: Decodable>(collection: String, 
                               document: String,
                               type: T.Type) -> AnyPublisher<T, FirestoreError> {
        return Future<T, FirestoreError> { promise in
            FIRESTORE.collection(collection).document(document).getDocument { snapShot, error in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                } else if let snapshot = snapShot, snapshot.exists {
                    do {
                        let data = try snapshot.data(as: T.self)
                        promise(.success(data))
                    } catch {
                        promise(.failure(.dataDecodingFailed))
                    }
                } else {
                    promise(.failure(.documentNotFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //UPDATE
    ///Field update
    ///Fields Update Method
    func updateData(collection: String, 
                    document: String,
                    fields: [String: Any]) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            FIRESTORE.collection(collection).document(document).updateData(fields) { error in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    ///Data Update
    ///All Data Update Method
    func updateData<T: Encodable>(collection: String, 
                                  document: String,
                                  data: T) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            do {
                
                let encodedData = try Firestore.Encoder().encode(data)
                
                FIRESTORE.collection(collection).document(document).setData(encodedData) { error in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(.dataEncodingFailed))
            }
        }
        .eraseToAnyPublisher()
    }

    
    //DELETE
    func deleteDocument(from collection: String, document: String) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            FIRESTORE.collection(collection).document(document).delete { error in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}
