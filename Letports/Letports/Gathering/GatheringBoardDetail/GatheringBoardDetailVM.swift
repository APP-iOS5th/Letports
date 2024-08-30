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
    @Published private(set) var comments: [Comment] = []
    
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
	
    func getBoardData() {
        getPost()
        getComment()
    }
    
    func getComment() {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(self.gathering.gatheringUid),
            .collection(.board),
            .document(self.boardPost.postUID),
            .collection(.comment)
        ]
        
        FM.getData(pathComponents: collectionPath, type: Comment.self)
            .sink { _ in
            } receiveValue: { [weak self] comments in
                self?.comments = comments
            }
            .store(in: &cancellables)
    }
    
    func addComment(comment: String, completionHandler: @escaping () -> Void) {
        
        let uuid = UUID().uuidString
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(self.gathering.gatheringUid),
            .collection(.board),
            .document(self.boardPost.postUID),
            .collection(.comment),
            .document(uuid)
        ]
        print("collectionPath", collectionPath)
        
        let comment = Comment(postUID: self.boardPost.postUID,
                              commentUID: uuid,
                              userUID: UserManager.shared.getUserUid(),
                              contents: comment,
                              createDate: Date().toString())
        
        FM.setData(pathComponents: collectionPath, data: comment)
            .sink { completion in
                switch completion {
                case .finished:
                    completionHandler()
                case .failure(let error):
                    print("comment upload Error \(error)")
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
	}
    
    func getUserData(userUid: String, completion: @escaping (Result<LetportsUser, FirestoreError>) -> Void) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(userUid)
        ]
        
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { users in
                if let user = users.first {
                    completion(.success(user))
                } else {
                    completion(.failure(.documentNotFound))
                }
            })
            .store(in: &cancellables)
    }
    
	func boardDetailBackBtnTap() {
		delegate?.boardDetailBackBtnTap()
	}
    
    func naviRightBtnDidTap() {
        delegate?.presentActionSheet(post: self.boardPost)
    }
    
    func getPost() {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.board),
            .document(boardPost.postUID)
        ]
        
        FM.getData(pathComponents: collectionPath, type: Post.self)
            .sink { _ in
            } receiveValue: { [weak self] post in
                guard let post = post.first else {
                    return
                }
                self?.boardPost = post
            }
            .store(in: &cancellables)
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
    
}

