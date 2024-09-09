//
//  GatheringVM.swift
//  Letports
//
//  Created by 홍준범 on 8/23/24.
//

import Foundation
import Combine
import FirebaseFirestore

enum GatheringCellType {
    case recommendGatheringHeader
    case recommendGatherings
    case gatheringListHeader
    case gatheringLists
    case recommendGatheringEmptyState
    case gatheringListEmptyState
}

class GatheringVM {
    @Published var recommendGatherings: [(Gathering, SportsTeam)] = []
    @Published var gatheringLists: [(Gathering, SportsTeam)] = []
    @Published var masterUsers: [String: LetportsUser] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore()
    
    weak var delegate: GatheringCoordinatorDelegate?
    
    func presentTeamChangeController() {
        self.delegate?.presentTeamChangeController()
    }
    
    func pushGatheringDetailController(gatheringUid: String, teamColor: String) {
        self.delegate?.pushGatheringDetailController(gatheringUid: gatheringUid, teamColor: teamColor)
    }
    
    func pushGatheringUploadController() {
        self.delegate?.pushGatheringUploadController()
    }
    
    private var cellType: [GatheringCellType] {
        var cellTypes: [GatheringCellType] = [.recommendGatheringHeader]
        cellTypes.append(contentsOf: recommendGatherings.isEmpty ?
                         [.recommendGatheringEmptyState] : Array(repeating: .recommendGatherings,
                                                                 count: recommendGatherings.count))
        cellTypes.append(.gatheringListHeader)
        cellTypes.append(contentsOf: gatheringLists.isEmpty ?
                         [.gatheringListEmptyState] : Array(repeating: .gatheringLists,
                                                            count: gatheringLists.count))
        return cellTypes
    }
    
    func getCellTypes() -> [GatheringCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    init() {
        loadTeam()
    }
    
    func loadTeam() {
        UserManager.shared.getTeam { result in
            switch result {
            case .success(let team):
                self.loadGatherings(forTeam: team.teamUID)
            case .failure(let error):
                print("getTeam Error \(error)")
            }
        }
    }
    
    func loadGatherings(forTeam teamName: String) {
        db.collection("Gatherings")
            .whereField("GatheringSportsTeam", isEqualTo: teamName)
            .getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error fetching gatherings: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                let gatherings = documents.compactMap { document in
                    try? document.data(as: Gathering.self)
                }
                
                let sortedGatherings = gatherings.sorted { gathering1, gathering2 in
                    return gathering1.gatheringCreateDate.dateValue() < gathering2.gatheringCreateDate.dateValue()
                }
                let filteredGatherings = sortedGatherings.filter { $0.gatherNowMember < $0.gatherMaxMember }
                
                self?.fetchSportsTeams(forGatherings: filteredGatherings)
            }
    }
    
    func getRecommendGatheringCount() -> Int {
        return self.recommendGatherings.count
    }
    
    private func fetchSportsTeams(forGatherings gatherings: [Gathering]) {
        let sportsTeamPublishers = gatherings.map { gathering in
            let collectionPath: [FirestorePathComponent] = [
                .collection(.sports),
                .document(gathering.gatheringSports),
                .collection(.sportsTeam),
                .document(gathering.gatheringSportsTeam)
            ]
            
            return FM.getData(pathComponents: collectionPath, type: SportsTeam.self)
                .map { sportsTeam -> (Gathering, SportsTeam) in
                    return (gathering, sportsTeam.first!)
                }
                .eraseToAnyPublisher()
        }
        Publishers.MergeMany(sportsTeamPublishers)
            .collect()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching sports teams: \(error)")
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                
                self.recommendGatherings = Array(results.prefix(2))
                
                self.gatheringLists = results
            })
            .store(in: &cancellables)
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
}


