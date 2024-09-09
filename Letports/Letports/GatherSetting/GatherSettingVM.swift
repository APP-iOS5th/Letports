import UIKit
import Combine
import FirebaseFirestore
import FirebaseStorage

enum GatheringSettingCellType {
    case pendingGatheringUserTtitle
    case pendingGatheringUser
    case pendingEmptyState
    case joiningGatheringUserTitle
    case joiningGatheringUser
    case joinEmptyState
    case settingTitle
    case deleteGathering
}

class GatherSettingVM {
    @Published var gathering: Gathering?
    @Published var joinedMembers: [GatheringMember] = []
    @Published var joinedMembersData: [LetportsUser] = []
    @Published var pendingMembers: [GatheringMember] = []
    @Published var pendingMembersData: [LetportsUser] = []
    @Published var allUserUIDs: [String] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: GatherSettingCoordinatorDelegate?
    
    private var cellType: [GatheringSettingCellType] {
        var cellTypes: [GatheringSettingCellType] = []
        cellTypes.append(.pendingGatheringUserTtitle)
        for _ in pendingMembers {
            cellTypes.append(.pendingGatheringUser)
        }
        if pendingMembers.count == 0 {
            cellTypes.append(.pendingEmptyState)
        }
        cellTypes.append(.joiningGatheringUserTitle)
        for _ in joinedMembers {
            cellTypes.append(.joiningGatheringUser)
        }
        if joinedMembers.count == 0 {
            cellTypes.append(.joinEmptyState)
        }
        cellTypes.append(.settingTitle)
        cellTypes.append(.deleteGathering)
        return cellTypes
    }
    
    init(gathering: Gathering) {
        self.gathering = gathering
        fetchGatheringMembers(gathering: gathering)
    }
    
    func denyUser(userUid: String) -> AnyPublisher<Void, FirestoreError> {
        let gatheringCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering?.gatheringUid ?? ""),
            .collection(.gatheringMembers),
            .document(userUid)
        ]
        
        let userMyGatheringPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(userUid),
            .collection(.myGathering),
            .document(gathering?.gatheringUid ?? "")
        ]
        return Publishers.Zip(
            FM.deleteDocument(pathComponents: gatheringCollectionPath),
            FM.deleteDocument(pathComponents: userMyGatheringPath)
        )
        .map { _, _ in () }
        .eraseToAnyPublisher()
    }
    
    func approveUser(userUid: String) -> AnyPublisher<Void, FirestoreError>{
        
        let gatheringMemberCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering?.gatheringUid ?? ""),
            .collection(.gatheringMembers),
            .document(userUid)
        ]
        
        let joinDate = Date().toString(format: "yyyy-MM-dd")
        
        let fieldsToUpdate: [String: Any] = [
            "JoinStatus": "joined",
            "JoinDate": joinDate
        ]
        
        let gatheringCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering?.gatheringUid ?? ""),
        ]
        
        let newNowMember = max((gathering?.gatherNowMember ?? 0) + 1, 0)
        let updatedFields: [String: Any] = [
            "GatherNowMember": newNowMember
        ]
        
        return Publishers.Zip(
            FM.updateData(pathComponents: gatheringMemberCollectionPath, fields: fieldsToUpdate),
            FM.updateData(pathComponents: gatheringCollectionPath, fields:  updatedFields)
        )
        .map { _, _ in () }
        .eraseToAnyPublisher()
        
    }
    
    func deleteGatheringButtonTapped()-> AnyPublisher<Void, FirestoreError>{
        isLoading = true
        return deleteAllGatheringMembers()
            .flatMap { [weak self] in
                self?.deleteGatheringImage() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .flatMap { [weak self] in
                self?.deleteBoardImages() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .flatMap { [weak self] in
                self?.deleteGatheringDocument() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
                self?.delegate?.gatherDeleteFinish()
            })
            .eraseToAnyPublisher()
    }
    
    func deleteAllGatheringMembers() -> AnyPublisher<Void, FirestoreError> {
        guard let gatheringUid = gathering?.gatheringUid else {
            return Fail(error: FirestoreError.documentNotFound).eraseToAnyPublisher()
        }
        
        let gatheringMembersCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gatheringUid),
            .collection(.gatheringMembers)
        ]
        
        return FM.getData(pathComponents: gatheringMembersCollectionPath, type: GatheringMember.self)
            .flatMap { [weak self] gatheringMembers -> AnyPublisher<Void, FirestoreError> in
                let deletePublishers = gatheringMembers.map { member -> AnyPublisher<Void, FirestoreError> in
                    
                    let userMyGatheringPath: [FirestorePathComponent] = [
                        .collection(.user),
                        .document(member.userUID),
                        .collection(.myGathering),
                        .document(gatheringUid)
                    ]
                    
                    let gatheringMemberPath: [FirestorePathComponent] = [
                        .collection(.gatherings),
                        .document(gatheringUid),
                        .collection(.gatheringMembers),
                        .document(member.userUID)
                    ]
                    
                    return Publishers.Zip(
                        FM.deleteDocument(pathComponents: userMyGatheringPath),
                        FM.deleteDocument(pathComponents: gatheringMemberPath)
                    )
                    .map { _, _ in () }
                    .mapError { _ in FirestoreError.deleteFailed }
                    .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(deletePublishers)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .mapError { _ in FirestoreError.dataDecodingFailed }
            .eraseToAnyPublisher()
    }
    
    func deleteGatheringImage() -> AnyPublisher<Void, FirestoreError> {
        guard let imageUrlString = gathering?.gatherImage else {
            return Just(()).setFailureType(to: FirestoreError.self).eraseToAnyPublisher()
        }
        let storageReference = Storage.storage().reference(forURL: imageUrlString)
        
        return Future<Void, FirestoreError> { promise in
            storageReference.delete { error in
                if let error = error {
                    print("Error deleting gathering image: \(error.localizedDescription)")
                    promise(.failure(.unknownError(error)))
                } else {
                    print("Successfully deleted gathering image.")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    
    func deleteBoardImages() -> AnyPublisher<Void, FirestoreError> {
        guard let gatheringUid = gathering?.gatheringUid else {
            return Fail(error: FirestoreError.documentNotFound).eraseToAnyPublisher()
        }
        
        let boardCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gatheringUid),
            .collection(.board)
        ]
        
        return FM.getData(pathComponents: boardCollectionPath, type: Post.self)
            .flatMap { [weak self] boardDocuments -> AnyPublisher<Void, FirestoreError> in
                let deletePublishers = boardDocuments.flatMap { document -> [AnyPublisher<Void, FirestoreError>] in
                    document.imageUrls.compactMap { imageUrlString in
                        self?.deleteImageFromStorage(imageUrlString: imageUrlString)
                    }
                }
                
                let deleteBoardDocuments = boardDocuments.map { document -> AnyPublisher<Void, FirestoreError> in
                    let boardDocumentPath: [FirestorePathComponent] = [
                        .collection(.gatherings),
                        .document(gatheringUid),
                        .collection(.board),
                        .document(document.postUID)
                    ]
                    
                    return FM.deleteDocument(pathComponents: boardDocumentPath)
                }
                
                return Publishers.MergeMany(deletePublishers + deleteBoardDocuments)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .mapError { _ in FirestoreError.dataDecodingFailed }
            .eraseToAnyPublisher()
    }
    
    private func deleteImageFromStorage(imageUrlString: String) -> AnyPublisher<Void, FirestoreError> {
        let storageReference = Storage.storage().reference(forURL: imageUrlString)
        
        return Future<Void, FirestoreError> { promise in
            storageReference.delete { error in
                if let error = error {
                    print("Error deleting board image: \(error.localizedDescription)")
                    promise(.failure(.unknownError(error)))
                } else {
                    print("Successfully deleted board image.")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteGatheringDocument() -> AnyPublisher<Void, FirestoreError> {
        guard let gatheringUid = gathering?.gatheringUid else {
            return Fail(error: FirestoreError.documentNotFound).eraseToAnyPublisher()
        }
        
        let gatheringDocumentPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gatheringUid)
        ]
        
        return FM.deleteDocument(pathComponents: gatheringDocumentPath)
            .handleEvents(receiveSubscription: { _ in
                print("삭제 작업 시작: \(gatheringDocumentPath)")
            }, receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("문서 삭제 완료: \(gatheringDocumentPath)")
                case .failure(let error):
                    print("문서 삭제 실패: \(error)")
                }
            }, receiveCancel: {
                print("문서 삭제 작업이 취소되었습니다.")
            })
            .mapError { error -> FirestoreError in
                print("Firestore 삭제 오류: \(error.localizedDescription)")
                return FirestoreError.deleteFailed
            }
            .eraseToAnyPublisher()
    }
    
    
    func errorToString(error: Error) -> String {
        return error.localizedDescription
    }
    
    func expelUser(userUid: String) -> AnyPublisher<Void, FirestoreError> {
        let gatheringMemberCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering?.gatheringUid ?? ""),
            .collection(.gatheringMembers),
            .document(userUid)
        ]
        
        let userMyGatheringPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(userUid),
            .collection(.myGathering),
            .document(gathering?.gatheringUid ?? "")
        ]
        
        let gatheringCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering?.gatheringUid ?? ""),
        ]
        
        let newNowMember = max((gathering?.gatherNowMember ?? 0) - 1, 0)
        
        let updatedFields: [String: Any] = [
            "GatherNowMember": newNowMember
        ]
        
        return Publishers.Zip3(
            FM.deleteDocument(pathComponents: gatheringMemberCollectionPath),
            FM.deleteDocument(pathComponents: userMyGatheringPath),
            FM.updateData(pathComponents: gatheringCollectionPath, fields:  updatedFields)
        )
        .map { _, _, _ in () }
        .eraseToAnyPublisher()
    }
    
    
    func gatherSettingBackBtnTap() {
        delegate?.gatherSettingBackBtnTap()
    }
    
    func getCellTypes() -> [GatheringSettingCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func loadData() {
        if let gathering = gathering {
            fetchGatheringMembers(gathering: gathering)
        }
    }
    
    private func fetchGatheringMembers(gathering: Gathering) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.gatheringMembers)
        ]
        
        FM.getData(pathComponents: collectionPath, type: GatheringMember.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("fetchGatheringMembers->finished")
                case .failure(let error):
                    print("fetchGatheringMembers-> Error:", error.localizedDescription)
                }
            } receiveValue: { [weak self] fetchedGatheringMembers in
                guard let self = self else { return }
                
                let joinedMembers = fetchedGatheringMembers.filter {
                    $0.userUID != gathering.gatheringMaster && $0.joinStatus == "joined"
                }
                let pendingMembers = fetchedGatheringMembers.filter {
                    $0.userUID != gathering.gatheringMaster && $0.joinStatus == "pending"
                }
                self.allUserUIDs = (self.joinedMembers.map { $0.userUID } + self.pendingMembers.map { $0.userUID })
                              .filter { $0 != gathering.gatheringMaster }

                self.joinedMembers = joinedMembers
                self.pendingMembers = pendingMembers
                
                self.fetchUsersData(for: joinedMembers) { users in
                    self.joinedMembersData = self.sortUsers(users, by: joinedMembers.map { $0.userUID })
                }
                
                self.fetchUsersData(for: pendingMembers) { users in
                    self.pendingMembersData = self.sortUsers(users, by: pendingMembers.map { $0.userUID })
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchUsersData(for members: [GatheringMember], completion: @escaping ([LetportsUser]) -> Void) {
        let userFetchPublishers = members.map { member in
            let userPath: [FirestorePathComponent] = [
                .collection(.user),
                .document(member.userUID)
            ]
            return FM.getData(pathComponents: userPath, type: LetportsUser.self)
                .catch { error -> Empty<[LetportsUser], Never> in
                    print("Error fetching user data for user \(member.userUID): \(error.localizedDescription)")
                    return Empty<[LetportsUser], Never>()
                }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(userFetchPublishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching user data:", error.localizedDescription)
                }
            }, receiveValue: { users in
                completion(users.flatMap { $0 })
            })
            .store(in: &cancellables)
    }
    
    private func sortUsers(_ users: [LetportsUser], by uidOrder: [String]) -> [LetportsUser] {
        return users.sorted { user1, user2 in
            guard let index1 = uidOrder.firstIndex(of: user1.uid),
                  let index2 = uidOrder.firstIndex(of: user2.uid) else {
                return false
            }
            return index1 < index2
        }
    }
}

