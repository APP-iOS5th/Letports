import UIKit
import Combine
import FirebaseFirestore



enum GatheringSettingCellType {
    case pendingGatheringUserTtitle
    case pendingGatheringUser
    case joiningGatheringUserTitle
    case joiningGatheringUser
    case settingTitle
    case deleteGathering
}

class GatherSettingVM {
    @Published var gathering: Gathering?
    @Published var pendingGatheringMembers: [GatheringMember] = []
    @Published var joiningGatheringMembers: [GatheringMember] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private var cellType: [GatheringSettingCellType] {
        var cellTypes: [GatheringSettingCellType] = []
        cellTypes.append(.pendingGatheringUserTtitle)
        for _ in pendingGatheringMembers {
            cellTypes.append(.pendingGatheringUser)
        }
        cellTypes.append(.joiningGatheringUserTitle)
        for _ in joiningGatheringMembers {
            cellTypes.append(.joiningGatheringUser)
        }
        cellTypes.append(.settingTitle)
        cellTypes.append(.deleteGathering)
        return cellTypes
    }
    
    func getCellTypes() -> [GatheringSettingCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    init() {
        loadGathering(with: "gathering040")
    }
    
    
    func processUserAction(for user: GatheringMember, with gathering: Gathering, action: UserAction) {
        switch action {
        case .deny:
            handleDeny(for: user, in: gathering)
        case .approve:
            handleApprove(for: user, in: gathering)
        }
    }
    
    func handleDeny(for user: GatheringMember, in gathering: Gathering) {
        print("가입거절")
    }
    
    func handleApprove(for user: GatheringMember, in gathering: Gathering) {
      print("가입승인")
    }
    
    func loadGathering(with GatheringUid: String) {
        FM.getData(collection: "Gatherings", documnet: "GatheringUid", type: Gathering.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("loadGathering->finished")
                    break
                case .failure(let error):
                    print("loadGatherings->",error.localizedDescription)
                }
            } receiveValue: { [weak self] fetchedGathering in
                print("loadGathering->finished")
                print(fetchedGathering)
                self?.gathering = fetchedGathering
                self?.fetchGatheringMembers(for: fetchedGathering)
            }
            .store(in: &cancellables)
    }
    
    func fetchGatheringMembers(for gathering: Gathering) {
        guard !gathering.gatheringMembers.isEmpty else {
            self.pendingGatheringMembers = []
            self.joiningGatheringMembers = []
            return
        }
        FM.getData(collection: "Gatherings", documnet: gathering.gatheringUid, type: Gathering.self)
            .map { gathering in
                // 유저의 joinStatus에 따라 배열을 나눔
                let joining = gathering.gatheringMembers.filter { $0.joinStatus == "가입중" }
                let pending = gathering.gatheringMembers.filter { $0.joinStatus == "가입대기중" }
                return (joining, pending)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {  completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("loadGatheringUser->",error.localizedDescription)
                }
            }, receiveValue: { [weak self] (joining, pending) in
                self?.joiningGatheringMembers = joining
                self?.pendingGatheringMembers = pending
            })
            .store(in: &cancellables)
    }
    
    
}
