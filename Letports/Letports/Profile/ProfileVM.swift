import Foundation
import Combine

class ProfileVM {
    @Published var user: User?
    @Published var myGatherings: [Gathering] = []
    @Published var pendingGatherings: [Gathering] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRandomData()
    }
    
    private func loadRandomData() {
        
        let randomUser = User(
            uid: UUID().uuidString,
            nickname: "RandomUser",
            image: "profile_image",  
            email: "randomuser@example.com",
            simpleInfo: "This is a random user.",
            userSports: "Sport001",
            userSportsTeam: "Team001",
            myGathering: ["Gathering001", "Gathering002", "Gathering003"]
        )
        self.user = randomUser
        
        // 랜덤 소모임 생성
        let randomGatherings: [Gathering] = (1...3).map { index in
            Gathering(
                gatheringSports: "Gathering00\(index)",
                gatheringTeam: "Sport001",
                gatheringUID: "Team00\(index)",
                gatheringMaster: "Master001",
                gatheringName: "Random Gathering \(index)",
                gatheringImage: "gathering_image_\(index)",
                gatherMaxMember: 10,
                gatherNowMember: Int.random(in: 1...10),
                gatherInfo: "This is a description for gathering \(index).",
                gatherQuestion: "Why do you want to join?",
                gatheringMembers: [],
                gatheringCreateDate: Date()
            )
        }
        self.myGatherings = randomGatherings
        
        
        let randomPendingGatherings: [Gathering] = (1...3).map { index in
            Gathering(
                gatheringSports: "PendingGathering00\(index)",
                gatheringTeam: "Sport002",
                gatheringUID: "Team00\(index + 3)",
                gatheringMaster: "Master002",
                gatheringName: "Pending Gathering \(index)",
                gatheringImage: "pending_gathering_image_\(index)",
                gatherMaxMember: 10,
                gatherNowMember: Int.random(in: 1...10),
                gatherInfo: "This is a description for pending gathering \(index).",
                gatherQuestion: "Why do you want to join?",
                gatheringMembers: [],
                gatheringCreateDate: Date()
            )
        }
        self.pendingGatherings = randomPendingGatherings
    }
}
