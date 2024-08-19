//
//  GatheringDeatilVM.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import Foundation
import UIKit

// 게시판 버튼
protocol ButtonStateDelegate: AnyObject {
	func didChangeButtonState(_ button: UIButton, isSelected: Bool)
}

enum GatheringDetailCellType {
	case gatheringImage
	case gatheringTitle
	case gatheringInfo
	case gatheringProfile
	case currentMemLabel
	case boardButtonType
	case gatheringBoard
	case separator
}
// 게시판버튼 유형
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
	@Published var membershipStatus: MembershipStatus = .joined
	@Published var selectedBoardType: BoardButtonType = .all
	
	private var cellType: [GatheringDetailCellType] {
		var cellTypes: [GatheringDetailCellType] = []
		cellTypes.append(.gatheringImage)
		cellTypes.append(.gatheringTitle)
		cellTypes.append(.separator)
		cellTypes.append(.gatheringInfo)
		cellTypes.append(.currentMemLabel)
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
	
	func calculateBoardHeight() -> CGFloat {
			let numberOfRows = filteredBoardData.count
			let cellHeight: CGFloat = 50 + 12 // 각 셀의 높이
			return CGFloat(numberOfRows) * cellHeight
		}
	
	// 모임 타이틀
	struct GatheringHeader {
		let gatheringImage: String
		let gatheringName: String
		let gatheringMasterName: String
		let gatheringNowMember: String
		let gatheringMaxMember: String
	}
	
	// 더미데이터
	let GatheringHeaders = [
		GatheringHeader(gatheringImage: "sampleImage",
						gatheringName: "수호단",
						gatheringMasterName: "매드카우",
						gatheringNowMember: "4",
						gatheringMaxMember: "10")
	]
	
	// 프로필
	struct Profile {
		let userImage: String
		let userNickName: String
	}
	
	// 현재인원 더미데이터
	let profiles = [
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
		Profile(userImage: "porfileEX2", userNickName: "수호신대장")
	]
	
	struct BoardData {
		let title: String
		let createDate: String
		let boardType: BoardButtonType
	}
	
	var filteredBoardData: [BoardData] {
		switch selectedBoardType {
		case .all:
			return boardData
		case .noti, .free:
			return boardData.filter { $0.boardType == selectedBoardType }
		}
	}
	
	
	// 게시판 더미데이터
	let boardData = [
		BoardData(title: "자유게시", createDate: "2024/09/05", boardType: .free),
		BoardData(title: "자유게시", createDate: "2024/09/05", boardType: .free),
		BoardData(title: "자유게시", createDate: "2024/09/05", boardType: .free),
		BoardData(title: "자유게시", createDate: "2024/09/05", boardType: .free),
		BoardData(title: "자유게시", createDate: "2024/09/05", boardType: .free),
		BoardData(title: "공지게시", createDate: "2024/11/05", boardType: .noti),
		BoardData(title: "공지게시", createDate: "2024/11/05", boardType: .noti),
		BoardData(title: "공지게시", createDate: "2024/11/05", boardType: .noti),
		BoardData(title: "공지게시", createDate: "2024/11/05", boardType: .noti),
		BoardData(title: "공지게시", createDate: "2024/11/05", boardType: .noti),
	]
}



extension BoardButtonType {
	var description: String {
		switch self {
		case .all:
			return "전체"
		case .noti:
			return "공지"
		case .free:
			return "자유"
		}
	}
}
