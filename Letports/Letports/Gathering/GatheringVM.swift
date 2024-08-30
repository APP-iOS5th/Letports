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
}

class GatheringVM {
    @Published var recommendGatherings: [Gathering] = []
    @Published var gatheringLists: [Gathering] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore()
    
    weak var delegate: GatheringCoordinatorDelegate?
    
    func presentTeamChangeController() {
        
    }
    
    func pushGatheringDetailController(gatheringUid: String) {
        self.delegate?.pushGatheringDetailController(gatheringUid: gatheringUid)
    }
    
    func pushGatheringUploadController() {
        self.delegate?.pushGatheringUploadController()
    }
    
    
    private var cellType: [GatheringCellType] {
        var cellTypes: [GatheringCellType] = []
        cellTypes.append(.recommendGatheringHeader)
        for _ in recommendGatherings {
            cellTypes.append(.recommendGatherings)
        }
        cellTypes.append(.gatheringListHeader)
        for _ in gatheringLists {
            cellTypes.append(.gatheringLists)
        }
        return cellTypes
    }
    
    func getCellTypes() -> [GatheringCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    init() {
        loadGatherings(forTeam: "KIATigers")
    }
    
    //Gathering 정보 가져오기
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
                
                // Gathering 객체로 변환하여 recommendGatherings 및 gatheringLists에 저장
                let gatherings = documents.compactMap { document in
                    try? document.data(as: Gathering.self)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                self?.recommendGatherings = Array(gatherings.sorted { gathering1, gathering2 in
                    
                    guard
                        let date1 = dateFormatter.date(from: gathering1.gatheringCreateDate),
                        let date2 = dateFormatter.date(from: gathering2.gatheringCreateDate)
                    else {
                        return false
                    }
                    return date1 < date2
                }.prefix(2))
                self?.gatheringLists = gatherings
            }
    }
    
    func getRecommendGatheringCount() -> Int {
        return self.recommendGatherings.count
    }
}


