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
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return dictionary ?? [:]
    }
}

extension FirestoreManager {
    func getSportsCategories() -> AnyPublisher<[TeamSelectionViewModel.Sports], FirestoreError> {
        return Future<[TeamSelectionViewModel.Sports], FirestoreError> { promise in
            FIRESTORE.collection("Sports").getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                    return
                }
                
                let sportsCategories = querySnapshot?.documents.compactMap { document -> TeamSelectionViewModel.Sports? in
                    let id = document.documentID.replacingOccurrences(of: "Letports_", with: "")
                    let name = document.get("sports") as? String ?? id
                    return TeamSelectionViewModel.Sports(id: id, name: name)
                } ?? []
                
                promise(.success(sportsCategories))
            }
        }
        .eraseToAnyPublisher()
    }

    func getTeamsForSports(_ sports: String) -> AnyPublisher<[TeamSelectionViewModel.Team], FirestoreError> {
        return Future<[TeamSelectionViewModel.Team], FirestoreError> { promise in
            FIRESTORE.collection("Sports").document("Letports_\(sports)")
                .collection("SportsTeam").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        promise(.failure(.unknownError(error)))
                        return
                    }
                    
                    let teams = querySnapshot?.documents.compactMap { document -> TeamSelectionViewModel.Team? in
                        guard let teamName = document.get("TeamName") as? String,
                              let teamLogo = document.get("TeamLogo") as? String,
                              let teamUID = document.get("TeamUID") as? String else { return nil }
                        return TeamSelectionViewModel.Team(
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
