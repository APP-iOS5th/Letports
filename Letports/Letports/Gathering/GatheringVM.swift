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
	@Published var recommendGatherings: [SampleGathering1] = []
	@Published var gatheringLists: [SampleGathering1] = []
	
	private var cancellables = Set<AnyCancellable>()
	private var db = Firestore.firestore()
	
	weak var delegate: GatheringCoordinatorDelegate?
	
    init() {
        loadGatherings(forTeam: "KIATigers")
    }
    
	func presentTeamChangeController() {
	}
	
	func pushGatheringDetailController(gatheringUid: String ) {
		self.delegate?.pushGatheringDetailController(gatheringUid: gatheringUid)
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
					try? document.data(as: SampleGathering1.self)
				}
				
				self?.recommendGatherings = gatherings.filter { gathering in
					// 예시: 특정 조건에 맞는 소모임을 추천 소모임으로 필터링
					gathering.gatherNowMember < gathering.gatherMaxMember // 임의 조건
				}
				
				self?.gatheringLists = gatherings
			}
	}
	
	func getRecommendGatheringCount() -> Int {
		return self.recommendGatherings.count
	}
}


