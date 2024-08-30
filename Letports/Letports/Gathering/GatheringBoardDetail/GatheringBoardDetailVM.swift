//
//  GatheringBoardDetailVM.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit
import Combine

enum GatheringBoardDetailCellType {
	case boardProfileTitle
	case boardContents
	case separator
	case images
	case commentHeaderLabel
	case comment
}

protocol GatheringBoardDetailCoordinatorDelegate: AnyObject {
	func boardDetailBackBtnTap()
}

final class GatheringBoardDetailVM {
	@Published private(set) var boardPost: Post?
	private let allUsers: [LetportsUser]
	private var cancellables = Set<AnyCancellable>()
	weak var delegate: GatheringBoardDetailCoordinatorDelegate?
	
	init(boardPost: Post, allUsers: [LetportsUser]) {
		self.boardPost = boardPost
		self.allUsers = allUsers
	}
	
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
	
	func getUserInfoForCurrentPost() -> (nickname: String, imageUrl: String)? {
		guard let boardPost = self.boardPost else {
			return nil
		}
		
		if let user = allUsers.first(where: { $0.uid == boardPost.userUID }) {
			let result = (nickname: user.nickname, imageUrl: user.image)
			return result
		}
		
		return nil
	}
	
	func addComment(comment: String) {
		self.comment.append(Comment(nickName: "나 손흥민", writeDate: "2024-08-26 15:19", content: comment))
		print(self.comment)
	}
	
	func boardDetailBackBtnTap() {
		delegate?.boardDetailBackBtnTap()
	}
	
	// 댓글(삭제예정)
	struct Comment { // 퍼블리셔로
		let nickName: String
		let writeDate: String
		let content: String
	}
	
	var comment: [Comment] = [
		Comment(nickName: "황희찬", writeDate: "2024-07-11 17:12", content: "댓글 내용 1 - 황희찬님의 의견"),
		Comment(nickName: "이강인", writeDate: "2024-07-10 22:12", content: "댓글 내용 2 - 이강인님의 의견"),
		Comment(nickName: "손흥민", writeDate: "2024-07-12 08:12", content: "댓글 내용 3 - 손흥민님의 의견"),
		Comment(nickName: "김민재", writeDate: "2024-07-10 14:12", content: "댓글 내용 4 - 김민재님의 의견"),
		Comment(nickName: "김민재", writeDate: "2024-07-17 07:12", content: "댓글 내용 5 - 김민재님의 의견")
	]
	
}

