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
    
    func getCellTypes() -> [ProfileCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
//    init() {
//        loadUser()
//    }
    
//    func loadUser() {
//        FM.getData(collection: "Users", document: "user006", type: LetportsUser.self)
//            .sink { completion in
//                switch completion {
//                case .finished:
//                    print("loadUser->finished")
//                    break
//                case .failure(let error):
//                    print("loadUser->",error.localizedDescription)
//                }
//            } receiveValue: { [weak self] fetchedUser in
//               // print(fetchedUser)
//                self?.user = fetchedUser
//                self?.fetchUserGatherings(for: fetchedUser)
//            }
//            .store(in: &cancellables)
//    }
    
//    func loadUser(withUID uid: String) -> AnyPublisher<User, FirestoreError> {
//        return FM.getData(collection: "Users", documnet: uid, type: User.self)
//        }
    
    
//    func fetchUserGatherings(for user: LetportsUser) {
//        // 가져올 문서 ID가 있는지 확인
//        guard !user.myGathering.isEmpty else {
//            self.myGatherings = []
//            self.pendingGatherings = []
//            return
//        }
//        
//        // Gatherings 데이터를 가져오기
//        print(user.myGathering)
//        FM.getDocuments(collection: "Gatherings", documentIds: user.myGathering, type: Gathering.self)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    // 성공적으로 완료된 경우
//                    break
//                case .failure(let error):
//                    print("loadUserGathering->",error.localizedDescription)
//                }
//            }, receiveValue: { [weak self] gatherings in
//                guard let self = self else { return }
//                
//                // Gatherings 필터링
//                let (myGatherings, pendingGatherings) = self.filterGatherings(gatherings, for: user)
//                
//                // 필터링된 데이터를 @Published 변수에 저장
//                self.myGatherings = myGatherings
//                self.pendingGatherings = pendingGatherings
//            })
//            .store(in: &cancellables)
//    }
    
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

