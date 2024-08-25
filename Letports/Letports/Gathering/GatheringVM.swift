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
    case GatheringListHeader
    case GatheringLists
}

class GatheringVM {
    @Published var recommendGatherings: [Gathering] = []
    @Published var gatheringLists: [Gathering] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore()
    
    private var cellType: [GatheringCellType] {
        var cellTypes: [GatheringCellType] = []
        cellTypes.append(.recommendGatheringHeader)
        for _ in recommendGatherings {
            cellTypes.append(.recommendGatherings)
        }
        cellTypes.append(.GatheringListHeader)
        for _ in gatheringLists {
            cellTypes.append(.GatheringLists)
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
        loadGathering(with GatheringUID: String)
    }
    
    //Gathering 정보 가져오기 <도움 요청>
    func loadGatherings(forTeam teamName: String) {
        db.collection("Gatherings")
            .whereField("GatheringSportsTeam", isEqualTo: teamName)
            .getDocument { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error fetching gatherings: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                // Gathering 객체로 변환하여 allGatherings 배열에 저장
                self?.allGatherings = documents.compactMap { document in
                    try? document.data(as: Gathering.self)
                }
                
                // 여기서 추천 소모임을 별도로 필터링할 수 있습니다.
                self?.recommendedGatherings = self?.allGatherings.filter { gathering in
                    // 예: 현재 사용자와 관련된 추천 소모임만 필터링
                    // 사용자와 관련된 필터링 로직을 추가하세요.
                    // 지금은 예시로 allGatherings에서 임의의 하나를 추천 소모임으로 설정합니다.
                    gathering.gatherNowMember < gathering.gatherMaxMember // 임의 조건
                } ?? []
            }
    }
    
    
    
    
}
