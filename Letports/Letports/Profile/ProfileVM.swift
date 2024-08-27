import Foundation
import Combine
import FirebaseFirestore

enum ProfileCellType {
    case profile
    case myGatheringHeader
    case myGatherings
    case pendingGatheringHeader
    case pendingGatherings
}

class ProfileVM {
    @Published var user: LetportsUser?
    @Published var myGatherings: [Gathering] = []
    @Published var pendingGatherings: [Gathering] = []
    
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: ProfileCoordinatorDelegate?
    
    private var cellType: [ProfileCellType] {
        var cellTypes: [ProfileCellType] = []
        cellTypes.append(.profile)
        cellTypes.append(.myGatheringHeader)
        for _ in myGatherings {
            cellTypes.append(.myGatherings)
        }
        cellTypes.append(.pendingGatheringHeader)
        for _ in pendingGatherings {
            cellTypes.append(.pendingGatherings)
        }
        return cellTypes
    }
    
    init() {
        loadUser(with: "user011")
    }
    
    func getCellTypes() -> [ProfileCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func didTapDismiss() {
        self.delegate?.dismissViewController()
    }
    
    func profileEditButtonTapped() {
        self.delegate?.presentEditProfileController(user: user!)
    }
    
    func settingButtonTapped() {
        self.delegate?.presentSettingViewController()
    }
    
    func loadUser(with user: String) {
        FM.getData(collection: "Users", document: user, type: LetportsUser.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("loadUser->finished")
                    break
                case .failure(let error):
                    print("loadUser->",error.localizedDescription)
                }
            } receiveValue: { [weak self] fetchedUser in
                self?.user = fetchedUser
                self?.fetchUserGatherings(for: fetchedUser)
            }
            .store(in: &cancellables)
    }
    
    func fetchUserGatherings(for user: LetportsUser) {
        
        guard !user.myGathering.isEmpty else {
            self.myGatherings = []
            self.pendingGatherings = []
            return
        }
        
        FM.getDocuments(collection: "Gatherings", documentIds: user.myGathering, type: Gathering.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("loadUserGathering->finished")
                    break
                case .failure(let error):
                    print("loadUserGathering->",error.localizedDescription)
                }
            }, receiveValue: { [weak self] gatherings in
                guard let self = self else { return }
                
                let (myGatherings, pendingGatherings) = self.filterGatherings(gatherings, for: user)
                self.myGatherings = myGatherings
                self.pendingGatherings = pendingGatherings
               
            })
            .store(in: &cancellables)
    }
    
    private func filterGatherings(_ gatherings: [Gathering], for user: LetportsUser) -> ([Gathering], [Gathering]) {
        var myGatherings: [Gathering] = []
        var pendingGatherings: [Gathering] = []
        
        for gathering in gatherings {
            if gathering.gatheringMembers.contains(where: { $0.userUID == user.uid && ($0.joinStatus == "가입중" || $0.joinStatus == "마스터")}) {
                myGatherings.append(gathering)
            } else if gathering.gatheringMembers.contains(where: { $0.userUID == user.uid && $0.joinStatus == "가입대기중" }) {
                pendingGatherings.append(gathering)
            }
        }
        let pendingGatheringIDs = Set(pendingGatherings.map { $0.gatheringUid })
        myGatherings = myGatherings.filter { !pendingGatheringIDs.contains($0.gatheringUid) }
        return (myGatherings, pendingGatherings)
    }
    
}

