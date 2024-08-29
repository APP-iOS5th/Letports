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
	@Published private(set) var postAuthor: GatheringMember?
	private(set) var gathering: Gathering
	private var cancellables = Set<AnyCancellable>()
	weak var delegate: GatheringBoardDetailCoordinatorDelegate?
	
	init(postUID: String, gathering: Gathering) {
		self.gathering = gathering
		fetchBoardPost(postUID: postUID)
	}
	
	private func fetchBoardPost(postUID: String) {
		FirestoreManager.shared.getDocument(collection: "Board", documentId: postUID, type: Post.self)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .finished:
					print("게시글 데이터 가져오기 완료")
				case .failure(let error):
					print("게시글 데이터 가져오기 에러: \(error)")
				}
			}, receiveValue: { [weak self] post in
				self?.boardPost = post
				self?.fetchPostAuthor(userUID: post.userUID)
				self?.printBoardPostDetails()
			})
			.store(in: &cancellables)
	}
	
	private func fetchPostAuthor(userUID: String) {
		if let member = gathering.gatheringMembers.first(where: { $0.userUID == userUID }) {
			self.postAuthor = member
			printMemberDetails(member)
		} else {
			print("작성자 정보를 찾을 수 없습니다.")
		}
	}
	
	private func printMemberDetails(_ member: GatheringMember) {
//		print("=== 게시글 작성자 정보 ===")
//		print("닉네임: \(member.nickName)")
//		print("유저 UID: \(member.userUID)")
//		print("프로필 이미지 URL: \(member.image)")
//		print("가입 날짜: \(member.joinDate)")
//		print("가입 상태: \(member.joinStatus)")
//		print("답변: \(member.answer)")
//		print("간단 정보: \(member.simpleInfo)")
//		print("========================")
	}
	
	private func printBoardPostDetails() {
		guard let post = boardPost else {
			print("게시글 데이터가 없습니다.")
			return
		}
		
		print("=== 게시글 상세 정보 ===")
		print("postUID: \(post.postUID)")
		print("제목: \(post.title)")
		print("내용: \(post.contents)")
		print("게시판 타입: \(post.boardType)")
		print("작성자 UID: \(post.userUID)")
		print("이미지 URL 개수: \(post.imageUrls.count)")
		print("댓글 개수: \(post.comments.count)")
		print("========================")
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

