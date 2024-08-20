//
//  GatheringBoardDetailVM.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

enum GatheringBoardDetailCellType {
	case boardProfileTitle
	case boardContents
	case separator
	case images
	case commentHeaderLabel
	case commernt
}

final class GatheringBoardDetailVM {
	
	private var cellType: [GatheringBoardDetailCellType] {
		var cellTypes: [GatheringBoardDetailCellType] = []
		cellTypes.append(.boardProfileTitle)
		cellTypes.append(.boardContents)
		cellTypes.append(.separator)
		cellTypes.append(.images)
		cellTypes.append(.separator)
		cellTypes.append(.commentHeaderLabel)
		cellTypes.append(.commernt)
		return cellTypes
	}
	
	func getBoardDetailCount() -> Int {
		return self.cellType.count
	}
	
	func getBoardDetailCellTypes() -> [GatheringBoardDetailCellType] {
		return self.cellType
	}
	
	// 닉네임, 생성날짜,(삭제예정)
	struct BoardDetailTitle {
		let image: String
		let nickName: String
		let createDate: String
	}
	
	// 게시판상세이미지들(삭제예정)
	struct BoardDetailImage {
		let images: [String]
	}
	// 댓글(삭제예정)
	struct BoardDetailComment {
		let contents: String
		let writeDate: Date
	}
	
	
}

