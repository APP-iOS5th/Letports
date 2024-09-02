import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

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
        var cellTypes: [ProfileCellType] = [.profile, .myGatheringHeader]
        cellTypes.append(contentsOf: myGatherings.isEmpty ? [.myGatheringEmptyState] : Array(repeating: .myGatherings, count: myGatherings.count))
        cellTypes.append(.pendingGatheringHeader)
        cellTypes.append(contentsOf: pendingGatherings.isEmpty ? [.pendingGatheringEmptyState] : Array(repeating: .pendingGatherings, count: pendingGatherings.count))
        return cellTypes
    }
    
    init() {
        loadUser(user: UserManager.shared.getUserUid())
    }
    
    func getCellTypes() -> [ProfileCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func editProfileBtnDidTap() {
        if let user = user {
            self.delegate?.presentEditProfileController(user: user)
        }
    }
    
    func gatheringCellDidTap(gatheringUID: String) {
        if let user = user {
            self.delegate?.presentGatheringDetailController(currentUser: user, gatheringUid: gatheringUID)
        }
    }
    
    func settingButtonTapped() {
        self.delegate?.presentSettingViewController()
    }
    
    func loadUser(user: String, completion: (() -> Void)? = nil) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(user),
        ]
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .sink { completionResult in
                switch completionResult {
                case .finished:
                    print("loadUser->finished")
                case .failure(let error):
                    print("loadUser->", error.localizedDescription)
                }
            } receiveValue: { [weak self] fetchedUser in
                guard let self = self else { return }
                if let user = fetchedUser.first {
                    self.fetchUserGatherings(user: user)
                    self.user = user
                    self.updateMasterUserInfo(for: user)
                    completion?()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateMasterUserInfo(for user: LetportsUser) {
        if masterUsers[user.uid] != nil {
            masterUsers[user.uid] = user
            reloadUserGatherings()
        }
    }
    
    private func reloadUserGatherings() {
        guard let user = self.user else { return }
        fetchUserGatherings(user: user)
    }
    
    func fetchMasterUser(masterId: String) {
        guard masterUsers[masterId] == nil else { return }
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(masterId),
        ]
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .compactMap { $0.first }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] masterUser in
                self?.masterUsers[masterId] = masterUser
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
            } receiveValue: { [weak self] gatherings in
                guard let self = self else { return }
                self.getDatas(gatherings: gatherings, user: user)
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
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] allGatherings in
                guard let self = self else { return }
                let flatGatherings = allGatherings.flatMap { $0 }
                self.filterGatherings(flatGatherings, user: user)
            })
            .store(in: &cancellables)
    }
    
    private func filterGatherings(_ gatherings: [Gathering], user: LetportsUser) {
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
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                self.myGatherings = results.filter { $0.1 }.map { $0.0 }
                self.pendingGatherings = results.filter { $0.2 }.map { $0.0 }
            })
            .store(in: &cancellables)
    }
}
