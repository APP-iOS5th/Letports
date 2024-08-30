import UIKit
import Combine
import FirebaseFirestore

enum GatheringSettingCellType {
    case pendingGatheringUserTtitle
    case pendingGatheringUser
    case pendingSeparator
    case joiningGatheringUserTitle
    case joiningGatheringUser
    case joinSeparator
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
    
    private var cellType: [GatheringSettingCellType] {
        var cellTypes: [GatheringSettingCellType] = []
        cellTypes.append(.pendingGatheringUserTtitle)
        for _ in pendingMembers {
            cellTypes.append(.pendingGatheringUser)
        }
        if pendingMembers.count == 0 {
            cellTypes.append(.pendingSeparator)
        }
        cellTypes.append(.joiningGatheringUserTitle)
        for _ in joinedMembers {
            cellTypes.append(.joiningGatheringUser)
        }
        if joinedMembers.count == 0 {
            cellTypes.append(.joinSeparator)
        }
        cellTypes.append(.settingTitle)
        cellTypes.append(.deleteGathering)
        return cellTypes
    }
    
    init(gathering: Gathering) {
        self.gathering = gathering
        fetchGatheringMembers(gathering: gathering)
    }
    
    func denyUser() {
        delegate?.denyJoinGathering()
    }
    
    func approveUser() {
        delegate?.approveJoinGathering()
    }
    
    func expelUser() {
        delegate?.expelGathering()
    }
    
    func cancel() {
        delegate?.cancel()
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
                    completion(users.flatMap { $0 })  // 모든 사용자 데이터를 단일 배열로 결합
                })
                .store(in: &cancellables)
        }
        
        private func sortUsers(_ users: [LetportsUser], by uidOrder: [String]) -> [LetportsUser] {
            // UID 순서에 맞게 사용자 데이터를 정렬합니다.
            return users.sorted { user1, user2 in
                guard let index1 = uidOrder.firstIndex(of: user1.uid),
                      let index2 = uidOrder.firstIndex(of: user2.uid) else {
                    return false
                }
                return index1 < index2
            }
        }
}
