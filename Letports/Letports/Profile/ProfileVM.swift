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
        loadUser(with: "users001")
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
    
    func loadMasterUser(with master: String) -> Future<LetportsUser, Error> {
        return Future { promise in
            FM.getData(collection: "Users", document: master, type: LetportsUser.self)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } receiveValue: { fetchedUser in
                    promise(.success(fetchedUser))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchUserGatherings(for user: LetportsUser) {
        
        guard !user.myGathering.isEmpty else {
            self.myGatherings = []
            self.pendingGatherings = []
            return
        }
        
        
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
			.document(user.uid),
            .collection(.myGathering)
        ]
        
        FM.getData(pathComponents: collectionPath, type: MyGatherings.self)
            .sink { _ in
            } receiveValue: { [weak self] gathering in
                guard let self = self else { return }
                self.getDatas(gatherings: gathering)
                
            }
            .store(in: &cancellables)
    }
    
    func getDatas(gatherings: [MyGatherings]) {
        let gatheringPublishers = gatherings.map { gathering in
                let collectionPath3: [FirestorePathComponent] = [
                    .collection(.gatherings),
                    .document(gathering.uid)
                ]
                
                return FM.getData(pathComponents: collectionPath3, type: Gathering.self)
            }

            // 여러 Publisher를 병합하여 동시에 처리하고, 결과를 수집
            Publishers.MergeMany(gatheringPublishers)
                .collect() // 모든 결과를 한 번에 수집
                .sink(receiveCompletion: { _ in
                }, receiveValue: { [weak self] allGatherings in
                    guard let self = self else { return }
                    guard let user = self.user else { return }
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
                    .map { members -> (Gathering, Bool) in
                        let isJoined = members.contains { $0.userUID == user.uid && $0.joinStatus == "joined" }
                        return (gathering, isJoined)
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
                    
                    results.forEach { gathering, isJoined in
                        if isJoined {
                            myGatherings.append(gathering)
                        } else {
                            pendingGatherings.append(gathering)
                        }
                    }
                    
                    self.myGatherings = myGatherings
                    self.pendingGatherings = pendingGatherings
                })
                .store(in: &cancellables)
    }
    
}

