//
//  GatheringDeatilVM.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import Foundation
import UIKit

protocol ButtonStateDelegate: AnyObject {
	func didChangeButtonState(_ button: UIButton, isSelected: Bool)
}

enum GatheringDetailCellType {
	case gatheringImageTitle
	case gatheringInfo
	case gatheringProfile
	case boardButtonType
	case gatheringBoard
	case separator
}
// 게시판 유형
enum BoardButtonType {
	case all
	case noti
	case free
}
// 가입상태
enum MembershipStatus {
	case notJoined
	case pending
	case joined
}

class GatheringDetailVM {
	@Published var isMaster: Bool = true
	@Published var membershipStatus: MembershipStatus = .pending
	
	private var cellType: [GatheringDetailCellType] {
		var cellTypes: [GatheringDetailCellType] = []
		cellTypes.append(.gatheringImageTitle)
		cellTypes.append(.separator)
		cellTypes.append(.gatheringInfo)
		cellTypes.append(.gatheringProfile)
		cellTypes.append(.separator)
		cellTypes.append(.boardButtonType)
		cellTypes.append(.separator)
		cellTypes.append(.gatheringBoard)
		return cellTypes
	}
	
	func getDetailCellCount() -> Int {
		return self.cellType.count
	}
	
	func getDetailCellTypes() -> [GatheringDetailCellType] {
		return self.cellType
	}
	
	
	struct GatheringHeader {
		let gatheringImage: String
		let gatheringName: String
		let gatehringMasterName: String
		let gatheringNowMember: String
		let gatheringMaxMember: String
	}
	
	// 더미데이터
	let GatheringHeaders = [
		GatheringHeader(gatheringImage: "sampleImage",
						gatheringName: "수호단",
						gatehringMasterName: "매드카우",
						gatheringNowMember: "4",
						gatheringMaxMember: "10")
	]
	
	struct Profile {
		let userImage: String
		let userNickName: String
	}
	
	// 더미데이터
	let profiles = [
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장")
	]
}


