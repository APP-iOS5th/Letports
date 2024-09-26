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
    
    private(set) var gatheringUid: String?
    
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
    
    init(gatheringUid: String) {
        self.gatheringUid = gatheringUid
        self.loadData()
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
        
        let newNowMember = (gathering?.gatherNowMember ?? 0) + 1
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
    
    func deleteGatheringBtnDidTap() -> AnyPublisher<Void, FirestoreError> {
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
            .flatMap { [weak self] in
                self?.notifyAllMembersExceptMaster() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    self?.delegate?.gatherDeleteFinish()
                case .failure(let error):
                    print("삭제 작업 실패: \(error.localizedDescription)")
                }
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
            .flatMap { gatheringMembers -> AnyPublisher<Void, FirestoreError> in
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
        
        let newNowMember = (gathering?.gatherNowMember ?? 0) - 1
        
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
    
    private func notifyAllMembersExceptMaster() -> AnyPublisher<Void, FirestoreError> {
        guard let gatheringUid = gathering?.gatheringUid, let masterUid = gathering?.gatheringMaster else {
            return Fail(error: FirestoreError.documentNotFound).eraseToAnyPublisher()
        }
        
        let allMembersUIDs = joinedMembers.map { $0.userUID } + pendingMembers.map { $0.userUID }
        let memberUIDsToNotify = allMembersUIDs.filter { $0 != masterUid }
        
        let notificationPublishers = memberUIDsToNotify.map { uid in
            return NotificationService.shared.sendPushNotificationByUID(
                uid: uid,
                title: "소모임 삭제 알림",
                body: "\(self.gathering?.gatherName ?? "")소모임이 삭제되었습니다. "
            )
            .mapError { _ in FirestoreError.notificationFailed }
            .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(notificationPublishers)
            .collect()
            .map { _ in () }
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
        guard let gatheringUid = gatheringUid else {
            print("Gathering UID is missing")
            return
        }
        
        fetchGathering(by: gatheringUid)
            .flatMap { [weak self] gathering -> AnyPublisher<Void, FirestoreError> in
                guard let self = self else {
                    return Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
                }
                self.gathering = gathering
                return self.fetchGatheringMembers(gathering: gathering)
            }
            .sink { completion in
                switch completion {
                case .finished:
                    print("Data loading completed")
                case .failure(let error):
                    print("Data loading error:", error.localizedDescription)
                }
            } receiveValue: { _ in
                print("Members and users loaded successfully")
            }
            .store(in: &cancellables)
    }

    private func fetchGathering(by gatheringUid: String) -> AnyPublisher<Gathering, FirestoreError> {
        let gatheringPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gatheringUid)
        ]
        
        return FM.getData(pathComponents: gatheringPath, type: Gathering.self)
            .tryMap { gatherings in
                guard let gathering = gatherings.first else {
                    throw FirestoreError.documentNotFound
                }
                return gathering
            }
            .mapError { error in
                print("Error fetching gathering:", error.localizedDescription)
                return FirestoreError.dataDecodingFailed
            }
            .eraseToAnyPublisher()
    }

    private func fetchGatheringMembers(gathering: Gathering) -> AnyPublisher<Void, FirestoreError> {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.gatheringMembers)
        ]
        
        return FM.getData(pathComponents: collectionPath, type: GatheringMember.self)
            .flatMap { [weak self] members -> AnyPublisher<Void, FirestoreError> in
                guard let self = self else {
                    return Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
                }
                
                let filteredMembers = members.filter { $0.userUID != gathering.gatheringMaster }
                self.joinedMembers = filteredMembers.filter { $0.joinStatus == "joined" }
                self.pendingMembers = filteredMembers.filter { $0.joinStatus == "pending" }
                
                self.allUserUIDs = (self.joinedMembers.map { $0.userUID } + self.pendingMembers.map { $0.userUID })
                
                return self.fetchAllUsersData()
            }
            .map { _ in () }
            .mapError { error in
                print("Error fetching gathering members:", error.localizedDescription)
                return FirestoreError.dataDecodingFailed
            }
            .eraseToAnyPublisher()
    }

    private func fetchAllUsersData() -> AnyPublisher<Void, FirestoreError> {
        let allMembers = self.joinedMembers + self.pendingMembers
        return fetchUsersData(for: allMembers)
            .map { [weak self] users in
                guard let self = self else { return }
                
                let joinedUserUIDs = self.joinedMembers.map { $0.userUID }
                let pendingUserUIDs = self.pendingMembers.map { $0.userUID }
                
                self.joinedMembersData = self.sortUsers(users:users, by: joinedUserUIDs)
                self.pendingMembersData = self.sortUsers(users: users, by: pendingUserUIDs)

            }
            .eraseToAnyPublisher()
    }

    private func fetchUsersData(for members: [GatheringMember]) -> AnyPublisher<[LetportsUser], FirestoreError> {
        let userFetchPublishers = members.map { member in
            let userPath: [FirestorePathComponent] = [
                .collection(.user),
                .document(member.userUID)
            ]
            return FM.getData(pathComponents: userPath, type: LetportsUser.self)
                .catch { error -> Empty<[LetportsUser], Never> in
                    print("Error fetching user \(member.userUID):", error.localizedDescription)
                    return Empty<[LetportsUser], Never>()
                }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(userFetchPublishers)
            .collect()
            .map { users in
                return users.flatMap { $0 }
            }
            .mapError { error in
                print("Error fetching users:", error.localizedDescription)
                return FirestoreError.dataDecodingFailed
            }
            .eraseToAnyPublisher()
    
        
        return Publishers.MergeMany(userFetchPublishers)
            .collect()
            .map { users in
                return users.flatMap { $0 }
            }
            .mapError { error in
                print("Error fetching users:", error.localizedDescription)
                return FirestoreError.dataDecodingFailed
            }
            .eraseToAnyPublisher()
    }
    
    private func sortUsers(users: [LetportsUser], by uidOrder: [String]) -> [LetportsUser] {
           return users.sorted { user1, user2 in
               guard let index1 = uidOrder.firstIndex(of: user1.uid),
                     let index2 = uidOrder.firstIndex(of: user2.uid) else {
                   return false
               }
               return index1 < index2
           }
       }
}

