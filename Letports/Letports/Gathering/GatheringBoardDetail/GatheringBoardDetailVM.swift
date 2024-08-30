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
    case comment(comment: Comment)
}

protocol GatheringBoardDetailCoordinatorDelegate: AnyObject {
    func boardDetailBackBtnTap()
    func presentActionSheet(post: Post)
}

final class GatheringBoardDetailVM {
    @Published private(set) var boardPost: Post
    @Published private(set) var commentsWithUsers: [(comment: Comment, user: LetportsUser)] = []
    
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
        for commentWithUser in self.commentsWithUsers {
            cellTypes.append(.comment(comment: commentWithUser.comment))
        }
        
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
            .flatMap { [weak self] comments in
                self?.fetchUsersForComments(comments) ?? Just([]).eraseToAnyPublisher()
            }
            .sink { _ in
            } receiveValue: { [weak self] commentsWithUsers in
                self?.commentsWithUsers = commentsWithUsers
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
    
    private func fetchUsersForComments(_ comments: [Comment]) -> AnyPublisher<[(comment: Comment, 
                                                                                user: LetportsUser)], Never> {
        let userFetchers = comments.map { comment in
            return getUserData(userUid: comment.userUID)
                .map { user -> (comment: Comment, user: LetportsUser) in
                    return (comment: comment, user: user)
                }
                .replaceError(with: (comment: comment, user: LetportsUser(email: "", image: "", 
                                                                          nickname: "", simpleInfo: "",
                                                                          uid: "", userSports: "",
                                                                          userSportsTeam: "")))
        }
        
        return Publishers.MergeMany(userFetchers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func getUserData(userUid: String) -> AnyPublisher<LetportsUser, FirestoreError> {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(userUid)
        ]
        
        return FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .map { users in
                return users.first!
            }
            .eraseToAnyPublisher()
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

