import Foundation
import Combine
import FirebaseFirestore

enum ProfileCellType {
    case profile
    case myGatheringHeader
    case myGatherings
    case pendingGatheringHeader
    case pendingGatherings
    case myGatheringEmptyState
    case pendingGatheringEmptyState
}

class ProfileVM {
    @Published var user: LetportsUser?
    @Published var masterUsers: [String: LetportsUser] = [:]
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
        if myGatherings.count == 0 {
            cellTypes.append(.myGatheringEmptyState)
        }
        cellTypes.append(.pendingGatheringHeader)
        for _ in pendingGatherings {
            cellTypes.append(.pendingGatherings)
        }
        if pendingGatherings.count == 0 {
            cellTypes.append(.pendingGatheringEmptyState)
        }
        return cellTypes
    }
    
    init() {
        loadUser(user: "users002")
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
    
    func EditProfileBtnDidTap() {
        self.delegate?.presentEditProfileController(user: user!)
    }
    
    func gatheringCellDidTap(gatheringUID: String) {
        self.delegate?.presentGatheringDetailController(currentUser: user!, gatheringUid: gatheringUID)
    }
    
    func settingButtonTapped() {
        self.delegate?.presentSettingViewController()
    }
    
    func loadUser(user: String) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(user),
        ]
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("loadUser->finished")
                    break
                case .failure(let error):
                    print("loadUser->",error.localizedDescription)
                }
            } receiveValue: { [weak self] fetchedUser in
                if let user = fetchedUser.first{
                    self?.fetchUserGatherings(user: user)
                    self?.user = user
                }
            }
            .store(in: &cancellables)
    }
    
    
    func fetchMasterUser(masterId: String) {
        guard masterUsers[masterId] == nil else { return } // 이미 로드된 경우 로드하지 않음
        
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(masterId),
        ]
        
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .compactMap { $0.first }  // 첫 번째 사용자만 반환
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] masterUser in
                guard let self = self else { return }
                self.masterUsers[masterId] = masterUser
                // `@Published` 속성으로 바인딩되어 있으므로 ViewController에서 자동으로 UI 업데이트됨
            }
            .store(in: &cancellables)
    }
    
    func fetchUserGatherings(user: LetportsUser) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(user.uid),
            .collection(.myGathering)
        ]
        
        FM.getData(pathComponents: collectionPath, type: MyGatherings.self)
            .sink { _ in
            } receiveValue: { [weak self] gathering in
                guard let self = self else { return }
                self.getDatas(gatherings: gathering, user: user)
            }
            .store(in: &cancellables)
    }
    
    func getDatas(gatherings: [MyGatherings], user: LetportsUser) {
        let gatheringPublishers = gatherings.map { gathering in
            let collectionPath3: [FirestorePathComponent] = [
                .collection(.gatherings),
                .document(gathering.uid)
            ]
            return FM.getData(pathComponents: collectionPath3, type: Gathering.self)
        }
        
        Publishers.MergeMany(gatheringPublishers)
            .collect()
            .sink(receiveCompletion: { completion in
                switch  completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { [weak self] allGatherings in
                guard let self = self else { return }
                let flatGatherings = allGatherings.flatMap { $0 }
                self.filterGatherings(flatGatherings, user: user)
            })
            .store(in: &cancellables)
    }
    
    
    private func filterGatherings(_ gatherings: [Gathering],  user: LetportsUser) {
        let memberStatusPublishers = gatherings.map { gathering in
            let collectionPath3: [FirestorePathComponent] = [
                .collection(.gatherings),
                .document(gathering.gatheringUid),
                .collection(.gatheringMembers),
                .document(user.uid)
            ]
            
            return FM.getData(pathComponents: collectionPath3, type: GatheringMember.self)
                .map { members -> (Gathering, Bool, Bool) in
                    let isJoined = members.contains { $0.userUID == user.uid && $0.joinStatus == "joined" }
                    let isPending = members.contains { $0.userUID == user.uid && $0.joinStatus == "pending" }
                    return (gathering, isJoined, isPending)
                }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(memberStatusPublishers)
            .collect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                
                var myGatherings: [Gathering] = []
                var pendingGatherings: [Gathering] = []
                
                results.forEach { gathering, isJoined, isPending in
                    if isJoined {
                        myGatherings.append(gathering)
                    } else if isPending {
                        pendingGatherings.append(gathering)
                    }
                }
                
                self.myGatherings = myGatherings
                self.pendingGatherings = pendingGatherings
                
            })
            .store(in: &cancellables)
    }
    
}

