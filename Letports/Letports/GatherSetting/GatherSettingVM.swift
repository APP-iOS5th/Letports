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
    
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: GatherSettingCoordinatorDelegate?
    
    var alertPublisher = PassthroughSubject<(title: String, message: String, confirmAction: () -> Void, cancelAction: () -> Void), Never>()
    
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let joinDate = dateFormatter.string(from: Date())
        
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
        return deleteAllGatheringMembers()
            .flatMap { [weak self] in
                self?.deleteGatheringImage() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .flatMap { [weak self] in
                self?.deleteBoardImages() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .flatMap { [weak self] in
                self?.showCompletionAlert() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher() 
    }
    
    
    // 팝업을 Combine의 Future로 처리
    private func showCompletionAlert() -> AnyPublisher<Void, FirestoreError> {
        return Future { [weak self] promise in
            self?.delegate?.gatherDeleteFinish()
            promise(.success(())) // 성공적으로 완료되었음을 알림
        }
        .setFailureType(to: FirestoreError.self)
        .eraseToAnyPublisher()
    }
    
    // 1. 소모임 유저들의 MyGatherings 문서 삭제
    func deleteAllGatheringMembers() -> AnyPublisher<Void, FirestoreError> {
        guard let gatheringUid = gathering?.gatheringUid else {
            return Fail(error: FirestoreError.documentNotFound).eraseToAnyPublisher()
        }

        let gatheringMembersCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gatheringUid),
            .collection(.gatheringMembers)
        ]

        // 1. GatheringMember 문서들을 모두 가져옴
        return FM.getData(pathComponents: gatheringMembersCollectionPath, type: GatheringMember.self)
            .flatMap { [weak self] gatheringMembers -> AnyPublisher<Void, FirestoreError> in
                let deletePublishers = gatheringMembers.map { member -> AnyPublisher<Void, FirestoreError> in
                    // 멤버들의 MyGathering 컬렉션 내 문서를 삭제
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

                    // MyGathering에서 해당 문서와 소모임의 GatheringMember 문서도 삭제
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
    
    // 2. 소모임의 이미지 삭제
    func deleteGatheringImage() -> AnyPublisher<Void, FirestoreError> {
        guard let imageUrlString = gathering?.gatherImage else {
            return Just(()).setFailureType(to: FirestoreError.self).eraseToAnyPublisher() // 이미지가 없는 경우
        }
        
        let storageReference = Storage.storage().reference(forURL: imageUrlString)
        
        return Future<Void, FirestoreError> { promise in
            storageReference.delete { error in
                if let error = error {
                    print("Error deleting gathering image: \(error.localizedDescription)")
                    promise(.failure(.unknownError(error))) // 오류를 unknownError로 처리
                } else {
                    print("Successfully deleted gathering image.")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 3. 게시글의 이미지 배열에 있는 모든 사진 삭제
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
                
                return Publishers.MergeMany(deletePublishers)
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
    
    // 4. 소모임 문서 삭제
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
