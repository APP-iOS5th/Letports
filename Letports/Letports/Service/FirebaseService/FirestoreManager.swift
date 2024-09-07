//
//  FirestoreManager.swift
//  Letports
//
//  Created by Chung Wussup on 8/19/24.
//

import FirebaseFirestore
import Combine

enum FirestorePathComponent {
    case collection(LetportsCollection)
    case document(String)
}

enum LetportsCollection: String {
    case gatherings = "Gatherings"
    case user = "Users"
    case sports = "Sports"
    case sportsTeam = "SportsTeam"
    case board = "Board"
    case comment = "Comment"
    case myGathering = "MyGatherings"
    case gatheringMembers = "GatheringMembers"
}


enum FirestoreError: LocalizedError, Equatable {
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
    
    static func == (lhs: FirestoreError, rhs: FirestoreError) -> Bool {
           switch (lhs, rhs) {
           case (.documentNotFound, .documentNotFound),
                (.dataEncodingFailed, .dataEncodingFailed),
                (.dataDecodingFailed, .dataDecodingFailed),
                (.updateFailed, .updateFailed),
                (.deleteFailed, .deleteFailed):
               return true
           case (.unknownError(let lhsError), .unknownError(let rhsError)):
               return lhsError.localizedDescription == rhsError.localizedDescription
           default:
               return false
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
    
   
    
///**Create**
/// - 단일, 다중 Collection을 통합적 사용하기 위한 Method
///
///**[사용법]**
///
///1. FirestorePathComponent를 이용하여 path 변수를 만들어 줌.
///
///2. path에는 Collection이 하나일 수도, 여러개일 수도 있음.
///
///3. MainColletion, SubCollection 열거형을 사용하여 직접 Collection 명을 작성하지 않더라도 case별로 지정해줄 수 있음.
///
/// - Warning: 열거형 형태이지만 path를 만들어 줄 때 정확한 경로를 배열로 만들어 주어야 원하는 Collection에 값을 저장할 수 있음.
///
/// - Note: FirestorePathComponent는 아래와 같이 사용할 수 있음
/**```swift
let path: [FirestorePathComponent] = [
    .collection(MainCollection.user),
    .document("userID123"),
    .collection(SubCollection.board),
    .document("boardID456")]
```
*/
    func setData<T: Encodable>(pathComponents: [FirestorePathComponent], 
                               data: T) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            do {
                let encodedData = try Firestore.Encoder().encode(data)
                var reference: DocumentReference? = nil
                var collectionReference: CollectionReference? = nil
                
                for component in pathComponents {
                    switch component {
                    case .collection(let collection):
                        if let ref = reference {
                            collectionReference = ref.collection(collection.rawValue)
                        } else {
                            collectionReference = FIRESTORE.collection(collection.rawValue)
                        }
                    case .document(let document):
                        if let colRef = collectionReference {
                            reference = colRef.document(document)
                        } else {
                            promise(.failure(.unknownError(NSError(domain: "FirestoreError", 
                                                                   code: 0,
                                                                   userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                            return
                        }
                    }
                }
                
                guard let finalReference = reference else {
                    promise(.failure(.unknownError(NSError(domain: "FirestoreError", 
                                                           code: 0,
                                                           userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                    return
                }
                
                finalReference.setData(encodedData) { error in
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

    
    
    ///**Read**
    /// - 단일, 다중 Collection을 통합적 사용하기 위한 Method
    ///
    ///**[사용법]**
    ///
    ///1. FirestorePathComponent를 이용하여 path 변수를 만들어 줌.
    ///
    ///2. path에는 Collection이 하나일 수도, 여러개일 수도 있음.
    ///
    ///3. MainColletion, SubCollection 열거형을 사용하여 직접 Collection 명을 작성하지 않더라도 case별로 지정해줄 수 있음.
    ///
    /// - Warning: 열거형 형태이지만 path를 만들어 줄 때 정확한 경로를 배열로 만들어 주어야 원하는 Collection에 값을 저장할 수 있음.
    ///
    /// - Note: FirestorePathComponent는 아래와 같이 사용할 수 있음
    /**```swift
    let path: [FirestorePathComponent] = [
        .collection(MainCollection.user),
        .document("userID123"),
        .collection(SubCollection.board),
        .document("boardID456")]
    ```
    */
    func getData<T: Decodable>(pathComponents: [FirestorePathComponent],
                               type: T.Type) -> AnyPublisher<[T], FirestoreError> {
        return Future<[T], FirestoreError> { promise in
            var reference: DocumentReference? = nil
            var collectionReference: CollectionReference? = nil
            
            for component in pathComponents {
                switch component {
                case .collection(let collection):
                    if let ref = reference {
                        collectionReference = ref.collection(collection.rawValue)
                        reference = nil // 문서에서 컬렉션으로 이동했으므로 reference 초기화
                    } else if let colRef = collectionReference {
                        collectionReference = colRef // 이미 컬렉션 참조가 있을 때는 동일하게 유지
                    } else {
                        collectionReference = FIRESTORE.collection(collection.rawValue)
                    }
                case .document(let document):
                    if let colRef = collectionReference {
                        reference = colRef.document(document)
                        collectionReference = nil // 컬렉션에서 문서로 이동했으므로 collectionReference 초기화
                    } else {
                        promise(.failure(.unknownError(NSError(domain: "FirestoreError",
                                                               code: 0,
                                                               userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                        return
                    }
                }
            }
            
            if let finalReference = reference {
                // 단일 문서 처리
                finalReference.getDocument { snapShot, error in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                    } else if let snapshot = snapShot, snapshot.exists {
                        do {
                            let data = try snapshot.data(as: T.self)
                            promise(.success([data]))
                        } catch {
                            promise(.failure(.dataDecodingFailed))
                        }
                    } else {
                        promise(.failure(.documentNotFound))
                    }
                }
            } else if let finalCollectionReference = collectionReference {
                // 여러 문서 처리
                finalCollectionReference.getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                    } else if let snapshot = snapshot {
                        do {
                            let documents = try snapshot.documents.map { try $0.data(as: T.self) }
                            promise(.success(documents))
                        } catch {
                            promise(.failure(.dataDecodingFailed))
                        }
                    } else {
                        promise(.failure(.documentNotFound))
                    }
                }
            } else {
                promise(.failure(.unknownError(NSError(domain: "FirestoreError",
                                                       code: 0,
                                                       userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    
    
    ///**Update**
    /// - 단일, 다중 Collection을 통합적 사용하기 위한 Method
    ///
    ///**[사용법]**
    ///
    ///1. FirestorePathComponent를 이용하여 path 변수를 만들어 줌.
    ///
    ///2. path에는 Collection이 하나일 수도, 여러개일 수도 있음.
    ///
    ///3. MainColletion, SubCollection 열거형을 사용하여 직접 Collection 명을 작성하지 않더라도 case별로 지정해줄 수 있음.
    ///
    /// - Warning: 열거형 형태이지만 path를 만들어 줄 때 정확한 경로를 배열로 만들어 주어야 원하는 Collection에 값을 저장할 수 있음.
    ///
    /// - Note: FirestorePathComponent는 아래와 같이 사용할 수 있음
    /**```swift
    let path: [FirestorePathComponent] = [
        .collection(MainCollection.user),
        .document("userID123"),
        .collection(SubCollection.board),
        .document("boardID456")]
    ```
    */
    func updateData(pathComponents: [FirestorePathComponent], 
                    fields: [String: Any]) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            var reference: DocumentReference? = nil
            var collectionReference: CollectionReference? = nil
            
            for component in pathComponents {
                switch component {
                case .collection(let collection):
                    if let ref = reference {
                        collectionReference = ref.collection(collection.rawValue)
                    } else {
                        collectionReference = FIRESTORE.collection(collection.rawValue)
                    }
                case .document(let document):
                    if let colRef = collectionReference {
                        reference = colRef.document(document)
                    } else {
                        promise(.failure(.unknownError(NSError(domain: "FirestoreError", 
                                                               code: 0,
                                                               userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                        return
                    }
                }
            }
            
            guard let finalReference = reference else {
                promise(.failure(.unknownError(NSError(domain: "FirestoreError", 
                                                       code: 0,
                                                       userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                return
            }
            
            finalReference.updateData(fields) { error in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateData<T: Encodable>(pathComponents: [FirestorePathComponent],
                                  model: T) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            var reference: DocumentReference? = nil
            var collectionReference: CollectionReference? = nil
            
            for component in pathComponents {
                switch component {
                case .collection(let collection):
                    if let ref = reference {
                        collectionReference = ref.collection(collection.rawValue)
                    } else {
                        collectionReference = FIRESTORE.collection(collection.rawValue)
                    }
                case .document(let document):
                    if let colRef = collectionReference {
                        reference = colRef.document(document)
                    } else {
                        promise(.failure(.unknownError(NSError(domain: "FirestoreError",
                                                               code: 0,
                                                               userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                        return
                    }
                }
            }
            
            guard let finalReference = reference else {
                promise(.failure(.unknownError(NSError(domain: "FirestoreError",
                                                       code: 0,
                                                       userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                return
            }
            
            do {
                try finalReference.setData(from: model) { error in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(.unknownError(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    ///**Delete**
    /// - 단일, 다중 Collection을 통합적 사용하기 위한 Method
    ///
    ///**[사용법]**
    ///
    ///1. FirestorePathComponent를 이용하여 path 변수를 만들어 줌.
    ///
    ///2. path에는 Collection이 하나일 수도, 여러개일 수도 있음.
    ///
    ///3. MainColletion, SubCollection 열거형을 사용하여 직접 Collection 명을 작성하지 않더라도 case별로 지정해줄 수 있음.
    ///
    /// - Warning: 열거형 형태이지만 path를 만들어 줄 때 정확한 경로를 배열로 만들어 주어야 원하는 Collection에 값을 저장할 수 있음.
    ///
    /// - Note: FirestorePathComponent는 아래와 같이 사용할 수 있음
    /**```swift
    let path: [FirestorePathComponent] = [
        .collection(MainCollection.user),
        .document("userID123"),
        .collection(SubCollection.board),
        .document("boardID456")]
    ```
    */
    func deleteDocument(pathComponents: [FirestorePathComponent]) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            var reference: DocumentReference? = nil
            var collectionReference: CollectionReference? = nil
            
            for component in pathComponents {
                switch component {
                case .collection(let collection):
                    if let ref = reference {
                        collectionReference = ref.collection(collection.rawValue)
                    } else {
                        collectionReference = FIRESTORE.collection(collection.rawValue)
                    }
                case .document(let document):
                    if let colRef = collectionReference {
                        reference = colRef.document(document)
                    } else {
                        promise(.failure(.unknownError(NSError(domain: "FirestoreError", 
                                                               code: 0,
                                                               userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                        return
                    }
                }
            }
            
            guard let finalReference = reference else {
                promise(.failure(.unknownError(NSError(domain: "FirestoreError", 
                                                       code: 0,
                                                       userInfo: [NSLocalizedDescriptionKey: "Invalid path structure"]))))
                return
            }
            
            finalReference.delete { error in
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
