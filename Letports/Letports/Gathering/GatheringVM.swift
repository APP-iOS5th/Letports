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
    @Published var isLoading: Bool = false
    
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
    
    func getRecommendGatheringCount() -> Int {
        return self.recommendGatherings.count
    }
    
    init() {
        loadTeam()
    }
    
    func loadTeam() {
           isLoading = true
           UserManager.shared.getTeam { result in
               switch result {
               case .success(let team):
                   self.loadGatherings(forTeam: team.teamUID)
               case .failure(let error):
                   print("getTeam Error \(error)")
                   self.isLoading = false
               }
           }
       }
    
    func loadGatherings(forTeam teamName: String) {
        db.collection("Gatherings")
            .whereField("GatheringSportsTeam", isEqualTo: teamName)
            .getDocuments(source: .server) { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching gatherings: \(error)")
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    self.isLoading = false
                    return
                }
                
                let gatherings = documents.compactMap { document in
                    try? document.data(as: Gathering.self)
                }
                
                let sortedGatherings = gatherings.sorted { $0.gatheringCreateDate.dateValue() > $1.gatheringCreateDate.dateValue() }
                let filteredGatherings = sortedGatherings.filter { $0.gatherNowMember < $0.gatherMaxMember }
                
                self.fetchSportsTeams(forGatherings: filteredGatherings)
            }
    }
    
    private func fetchSportsTeams(forGatherings gatherings: [Gathering]) {
        let sportsTeamPublishers = gatherings.map { gathering in
            let sportsTeamPath: [FirestorePathComponent] = [
                .collection(.sports),
                .document(gathering.gatheringSports),
                .collection(.sportsTeam),
                .document(gathering.gatheringSportsTeam)
            ]
            
            let masterUserPath: [FirestorePathComponent] = [
                .collection(.user),
                .document(gathering.gatheringMaster)
            ]
            
            return Publishers.Zip(
                FM.getData(pathComponents: sportsTeamPath, type: SportsTeam.self),
                FM.getData(pathComponents: masterUserPath, type: LetportsUser.self)
            )
            .map { sportsTeam, masterUser in
                return (gathering, sportsTeam.first!, masterUser.first!)
            }
            .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(sportsTeamPublishers)
            .collect()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching sports teams or master user: \(error)")
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                
                self.recommendGatherings = Array(results.prefix(2)).map { ($0.0, $0.1) }
                self.gatheringLists = results.map { ($0.0, $0.1) }
                self.updateMasterUsers(results: results)
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    private func updateMasterUsers(results: [(Gathering, SportsTeam, LetportsUser)]) {
        for result in results {
            let (_, _, masterUser) = result
            self.masterUsers[masterUser.uid] = masterUser
        }
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
                self?.masterUsers[masterId] = masterUser
            }
            .store(in: &cancellables)
    }
}


