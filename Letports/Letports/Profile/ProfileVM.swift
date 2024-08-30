import Foundation
import Combine
import FirebaseFirestore

enum ProfileCellType {
    case profile
    case myGatheringHeader
    case myGatherings
    case pendingGatheringHeader
    case pendingGatherings
    case myGatheringSeparator
    case pendingGatheringSeparator
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
        if myGatherings.count == 0 {
            cellTypes.append(.myGatheringSeparator)
        }
        cellTypes.append(.pendingGatheringHeader)
        for _ in pendingGatherings {
            cellTypes.append(.pendingGatherings)
        }
        if pendingGatherings.count == 0 {
            cellTypes.append(.pendingGatheringSeparator)
        }
        return cellTypes
    }
    
    init() {
        loadUser(with: "users002")
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
    
    func gatheringCellTapped(gatheringUID: String) {
        self.delegate?.presentGatheringDetailController(currentUser: user!, gatheringUid: gatheringUID)
    }
    
    func settingButtonTapped() {
        self.delegate?.presentSettingViewController()
    }
    
    func loadUser(with user: String) {
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
                self?.user = fetchedUser.first!
                let users = fetchedUser.first!
                self?.fetchUserGatherings(for: users)
            }
            .store(in: &cancellables)
    }
    
    func loadMasterUser(with master: String) -> Future<LetportsUser, Error> {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(master),
        ]
        return Future { promise in
            FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } receiveValue: { fetchedUser in
                    promise(.success(fetchedUser.first!))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchUserGatherings(for user: LetportsUser) {
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
                self.filterGatherings(flatGatherings, for: user)
            })
            .store(in: &cancellables)
    }
    
    
    private func filterGatherings(_ gatherings: [Gathering], for user: LetportsUser) {
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

