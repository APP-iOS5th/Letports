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
    case userGatheringHeader
    case userGatherings
    case myGatheringEmptyState
    case pendingGatheringEmptyState
}

enum ProfileType {
    case myProfile
    case userProfile
}

class ProfileVM {
    @Published var user: LetportsUser?
    @Published var myGatherings: [Gathering] = []
    @Published var pendingGatherings: [Gathering] = []
    @Published var userGatherings: [Gathering] = []
    @Published var masterUsers: [String: LetportsUser] = [:]
    @Published var currentUserUid: String?
    private var cancellables = Set<AnyCancellable>()
    let profileType: ProfileType
    
    weak var delegate: ProfileCoordinatorDelegate?
    
    init(profileType: ProfileType, userUID: String) {
        self.currentUserUid = userUID
        self.profileType = profileType
        switch profileType {
        case .myProfile:
            loadMyProfile()
        case .userProfile:
            if let currentUserUid = currentUserUid {
                loadUserProfile(userUID: currentUserUid)
            }
        }
    }
    
    private func loadMyProfile() {
        let userUID = UserManager.shared.getUserUid()
        loadUser(user: userUID) {
            self.fetchUserGatherings(userUID: userUID, isCurrentUser: true)
        }
    }
    
    private func loadUserProfile(userUID: String) {
        loadUser(user: userUID) {
            self.fetchUserGatherings(userUID: userUID, isCurrentUser: false)
        }
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
                    self.user = user
                    if self.profileType == .myProfile {
                        self.fetchUserGatherings(userUID: user.uid, isCurrentUser: true)
                    } else {
                        self.fetchUserGatherings(userUID: user.uid, isCurrentUser: false)
                    }
                    self.updateMasterUserInfo(for: user)
                    completion?()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateMasterUserInfo(for user: LetportsUser) {
        masterUsers[user.uid] = user
        reloadUserGatherings()
    }
    
    private func reloadUserGatherings() {
        guard let user = self.user else { return }
        fetchUserGatherings(userUID: user.uid, isCurrentUser: profileType == .myProfile)
    }
    
    func fetchUserGatherings(userUID: String, isCurrentUser: Bool) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(userUID),
            .collection(.myGathering)
        ]
        
        FM.getData(pathComponents: collectionPath, type: MyGatherings.self)
            .sink { _ in
            } receiveValue: { [weak self] gatherings in
                guard let self = self else { return }
                self.getDatas(gatherings: gatherings, userUID: userUID, isCurrentUser: isCurrentUser)
            }
            .store(in: &cancellables)
    }
    
    func getDatas(gatherings: [MyGatherings], userUID: String, isCurrentUser: Bool) {
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
                if isCurrentUser {
                    self.filterGatherings(flatGatherings, userUID: userUID)
                } else {
                    self.filterUserGatherings(flatGatherings, userUID: userUID)
                }
            })
            .store(in: &cancellables)
    }
    
    private func filterGatherings(_ gatherings: [Gathering], userUID: String) {
        let memberStatusPublishers = gatherings.map { gathering in
            let collectionPath3: [FirestorePathComponent] = [
                .collection(.gatherings),
                .document(gathering.gatheringUid),
                .collection(.gatheringMembers),
                .document(userUID)
            ]
            return FM.getData(pathComponents: collectionPath3, type: GatheringMember.self)
                .map { members -> (Gathering, Bool, Bool) in
                    let isJoined = members.contains { $0.userUID == userUID && $0.joinStatus == "joined" }
                    let isPending = members.contains { $0.userUID == userUID && $0.joinStatus == "pending" }
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
    
    private func filterUserGatherings(_ gatherings: [Gathering], userUID: String) {
        let userStatusPublishers = gatherings.map { gathering in
            let collectionPath3: [FirestorePathComponent] = [
                .collection(.gatherings),
                .document(gathering.gatheringUid),
                .collection(.gatheringMembers),
                .document(userUID)
            ]
            return FM.getData(pathComponents: collectionPath3, type: GatheringMember.self)
                .map { members -> Gathering? in
                    let isJoined = members.contains { $0.userUID == userUID && $0.joinStatus == "joined" }
                    return isJoined ? gathering : nil
                }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(userStatusPublishers)
            .collect()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                self.userGatherings = results.compactMap { $0 }
            })
            .store(in: &cancellables)
    }
    
    func fetchMasterUser(masterId: String) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(masterId),
        ]
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .compactMap { $0.first }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] masterUser in
                guard let self = self else { return }
                self.masterUsers[masterId] = masterUser
            }
            .store(in: &cancellables)
    }
    
    func getCellTypes() -> [ProfileCellType] {
        var cellTypes: [ProfileCellType] = [.profile]
        switch profileType {
        case .myProfile:
            cellTypes.append(.myGatheringHeader)
            cellTypes.append(contentsOf: myGatherings.isEmpty ? [.myGatheringEmptyState] : Array(repeating: .myGatherings, count: myGatherings.count))
            cellTypes.append(.pendingGatheringHeader)
            cellTypes.append(contentsOf: pendingGatherings.isEmpty ? [.pendingGatheringEmptyState] : Array(repeating: .pendingGatherings, count: pendingGatherings.count))
        case .userProfile:
            cellTypes.append(.userGatheringHeader)
            if !userGatherings.isEmpty {
                cellTypes.append(contentsOf: Array(repeating: .userGatherings, count: userGatherings.count))
            }
        }
        return cellTypes
    }
    
    func getCellCount() -> Int {
        return getCellTypes().count
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
    
    func settingBtnDidTap() {
        self.delegate?.presentSettingViewController()
    }
    
    func backBtnDidTap() {
        self.delegate?.backToGatheringDetail()
    }
}
