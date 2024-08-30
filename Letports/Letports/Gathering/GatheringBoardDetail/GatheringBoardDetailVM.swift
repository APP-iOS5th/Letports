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
    func presentActionSheet(post: Post)
}

final class GatheringBoardDetailVM {
	@Published private(set) var boardPost: Post
	private(set) var allUsers: [LetportsUser]
	private var cancellables = Set<AnyCancellable>()
	weak var delegate: GatheringBoardDetailCoordinatorDelegate?
    private(set) var gathering: Gathering
    
    init(boardPost: Post, allUsers: [LetportsUser], gathering: Gathering) {
		self.boardPost = boardPost
		self.allUsers = allUsers
        self.gathering = gathering
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
    
    func naviRightBtnDidTap() {
        delegate?.presentActionSheet(post: self.boardPost)
    }
    
    func deletePost() {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.board),
            .document(boardPost.postUID)
        ]
        
        FM.deleteDocument(pathComponents: collectionPath)
            .sink { completion in
                switch completion{
                case .finished:
                    print("delete Finished")
                case .failure(let error):
                    print("delete Erro \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.delegate?.boardDetailBackBtnTap()
            }
            .store(in: &cancellables)
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

