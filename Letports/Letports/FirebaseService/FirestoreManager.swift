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
    
    func getDocument<T: Decodable>(collection: String, documentId: String, type: T.Type) -> AnyPublisher<T, FirestoreError> {
        Future { promise in
            FIRESTORE.collection(collection).document(documentId).getDocument { (document, error) in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                } else if let document = document, document.exists {
                    do {
                        let data = try document.data(as: T.self)
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
    
    // 문서 여러 개 가져오기
    func getDocuments<T: Decodable>(collection: String, documentIds: [String], type: T.Type) -> AnyPublisher<[T], FirestoreError> {
        let publishers = documentIds.map { id in
            self.getDocument(collection: collection, documentId: id, type: T.self)
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
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
    
    //Read SubCollection
    ///Collection 안에 있는 Collection 조회
    func getDataSubCollection<T: Decodable>(collection: String,
                                            document: String,
                                            subCollection: String,
                                            subdocument: String,
                                            type: T.Type) -> AnyPublisher<T, FirestoreError> {
        
        return Future<T, FirestoreError> { promise in
            let document = FIRESTORE.collection(collection).document(document)
            document.collection(subCollection).document(subdocument).getDocument { snapShot, error in
                
                if let error = error {
                    promise(.failure(.unknownError(error)))
                } else if let snapShot = snapShot, snapShot.exists {
                    do {
                        let data = try snapShot.data(as: T.self)
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
    
    func approveUser(collection: String, document: String, newStatus: String) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            let db = Firestore.firestore()
            let docRef = db.collection(collection).document(document)
            
            docRef.getDocument { (document, error) in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                    return
                }
                
                guard let document = document, document.exists, var data = document.data() else {
                    promise(.failure(.documentNotFound))
                    return
                }
                
                // Fetch the current array
                var array = data["GatherMembers"] as? [[String: Any]] ?? []
                
                // Update the `joinStatus` field for each item in the array
                for index in 0..<array.count {
                    var item = array[index]
                    item["joinStatus"] = newStatus
                    array[index] = item
                }
                
                // Update the document with the new array
                docRef.updateData(["GatherMembers": array]) { error in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                    } else {
                        promise(.success(()))
                    }
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
    
    // 특정 컬렉션의 모든 문서를 한 번의 쿼리로 가져옴
    func getAllDocuments<T: Decodable>(collection: String, type: T.Type) -> AnyPublisher<[T], FirestoreError> {
        return Future<[T], FirestoreError> { promise in
            FIRESTORE.collection(collection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    promise(.success([]))
                    return
                }
                
                let decodedDocuments = documents.compactMap { document -> T? in
                    do {
                        var data = document.data()
                        data["postUID"] = document.documentID
                        return try Firestore.Decoder().decode(T.self, from: data)
                    } catch {
                        print("디코딩 에러: \(error)")
                        return nil
                    }
                }
                
                promise(.success(decodedDocuments))
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
						print("snapShot,t: \(snapshot.data()),\(T.self)")
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
						print("snapShot,t: \(snapshot.documents),\(T.self)")
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
        
    func getSportsCategories() -> AnyPublisher<[TeamSelectVM.Sports], FirestoreError> {
        return Future<[TeamSelectVM.Sports], FirestoreError> { promise in
            FIRESTORE.collection("Sports").getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                    return
                }
                
                let sportsCategories = querySnapshot?.documents.compactMap { document -> TeamSelectVM.Sports? in
                    let id = document.documentID.replacingOccurrences(of: "Letports_", with: "")
                    let name = document.get("SportsName") as? String ?? id
                    let sportsUID = document.documentID
                    return TeamSelectVM.Sports(id: id, name: name, sportsUID: sportsUID)
                } ?? []
                
                promise(.success(sportsCategories))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getSportsTeams(_ sports: String) -> AnyPublisher<[TeamSelectVM.Team], FirestoreError> {
        return Future<[TeamSelectVM.Team], FirestoreError> { promise in
            FIRESTORE.collection("Sports").document("Letports_\(sports)")
                .collection("SportsTeam").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                        return
                    }
                    
                    let teams = querySnapshot?.documents.compactMap { document -> TeamSelectVM.Team? in
                        guard let teamName = document.get("TeamName") as? String,
                              let teamLogo = document.get("TeamLogo") as? String,
                              let teamUID = document.get("TeamUID") as? String else { return nil }
                        return TeamSelectVM.Team(
                            id: document.documentID,
                            name: teamName,
                            logoUrl: teamLogo,
                            sports: sports,
                            teamUID: teamUID
                        )
                    } ?? []
                    
                    promise(.success(teams))
                }
        }
        .eraseToAnyPublisher()
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return dictionary ?? [:]
    }
}
