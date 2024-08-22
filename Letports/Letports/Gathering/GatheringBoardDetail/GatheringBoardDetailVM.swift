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
	case comment
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
		cellTypes.append(.comment)
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
	struct Comment { // 퍼블리셔로
		let nickName: String
		let writeDate: String
		let content: String
	}
	
	let comment: [Comment] = [
		Comment(nickName: "황희찬", writeDate: "2024-07-11 17:12", content: "댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견댓글 내용 1 - 황희찬님의 의견"),
		Comment(nickName: "이강인", writeDate: "2024-07-10 22:12", content: "댓글 내용 2 - 이강인님의 의견"),
		Comment(nickName: "손흥민", writeDate: "2024-07-12 08:12", content: "댓글 내용 3 - 손흥민님의 의견"),
		Comment(nickName: "김민재", writeDate: "2024-07-10 14:12", content: "댓글 내용 4 - 김민재님의 의견"),
		Comment(nickName: "김민재", writeDate: "2024-07-17 07:12", content: "댓글 내용 5 - 김민재님의 의견")
	]
	
}

