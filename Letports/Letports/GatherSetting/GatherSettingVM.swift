import UIKit
import Combine
import FirebaseFirestore

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
    
    func deleteGathering() {
        print("테스트")
    }
    
    
    func errorToString(error: Error) -> String {
        return error.localizedDescription
    }
    
    func expelUser(userUid: String, nickName: String) -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { [weak self] promise in
            let confirmAction: () -> Void = { [weak self] in
                self?.performExpelUser(userUid: userUid)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("User expulsion completed.")
                            promise(.success(())) // 성공 시 promise를 호출합니다.
                        case .failure(let error):
                            print("Error expelling user: \(error.localizedDescription)")
                            promise(.failure(error)) // 실패 시 promise를 호출합니다.
                        }
                    }, receiveValue: {})
                    .store(in: &self!.cancellables)
            }
            
            let cancelAction: () -> Void = {
                print("Expel action was cancelled.")
                // 취소 시 수행할 작업을 추가하세요.
            }
            
            self?.alertPublisher.send((title: "확인", message: "정말로 \(nickName) 사용자를 추방하시겠습니까?", confirmAction: confirmAction, cancelAction: cancelAction))
        }
        .eraseToAnyPublisher()
    }
    
    func performExpelUser(userUid: String) -> AnyPublisher<Void, FirestoreError> {
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
