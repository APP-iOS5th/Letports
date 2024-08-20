import Foundation
import Combine
import FirebaseFirestore

class ProfileVM {
    @Published var user: User?
    @Published var myGatherings: [Gathering] = []
    @Published var pendingGatherings: [Gathering] = []
   
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUser(withUID: "user004")
    }
    
    func loadUser(withUID uid: String) {
       FM.getData(collection: "Users", documnet: uid, type: User.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching user: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] fetchedUser in
                self?.user = fetchedUser
                self?.fetchUserGatherings(for: fetchedUser)
            })
            .store(in: &cancellables)
    }
    
//    func loadUser(withUID uid: String) -> AnyPublisher<User, FirestoreError> {
//        return FM.getData(collection: "Users", documnet: uid, type: User.self)
//        }
    
    
    func fetchUserGatherings(for user: User) {
        // 가져올 문서 ID가 있는지 확인
        guard !user.myGathering.isEmpty else {
            self.myGatherings = []
            self.pendingGatherings = []
            return
        }
        
        // Gatherings 데이터를 가져오기
        FM.getDocuments(collection: "Gatherings", documentIds: user.myGathering, type: Gathering.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    // 성공적으로 완료된 경우
                    break
                case .failure(let error):
                    print("Error fetching user: \(error)")
                }
            }, receiveValue: { [weak self] gatherings in
                guard let self = self else { return }
                
                // Gatherings 필터링
                let (myGatherings, pendingGatherings) = self.filterGatherings(gatherings, for: user)
                
                // 필터링된 데이터를 @Published 변수에 저장
                self.myGatherings = myGatherings
                self.pendingGatherings = pendingGatherings
            })
            .store(in: &cancellables)
    }
    
    private func filterGatherings(_ gatherings: [Gathering], for user: User) -> ([Gathering], [Gathering]) {
        var myGatherings: [Gathering] = []
        var pendingGatherings: [Gathering] = []
        
        for gathering in gatherings {
            if gathering.gatheringMembers.contains(where: { $0.userUID == user.uid && $0.joinStatus == "가입중" }) {
                myGatherings.append(gathering)
            } else if gathering.gatheringMembers.contains(where: { $0.userUID == user.uid && $0.joinStatus == "가입대기중" }) {
                pendingGatherings.append(gathering)
            }
        }
        return (myGatherings, pendingGatherings)
    }
}

