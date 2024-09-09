//
//  GatheringBoardDetailVM.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit
import Combine
import FirebaseCore
import FirebaseStorage

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
    func presentActionSheet(post: Post, isWriter: Bool)
    func presentReportAlert()
    func presentDeleteBoardAlert()
}

final class GatheringBoardDetailVM {
    @Published private(set) var boardPost: Post
    @Published private(set) var commentsWithUsers: [(comment: Comment, user: LetportsUser)] = []
    @Published private(set) var isLoading: Bool = false
    
    
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
    
    func getPostDate() -> String {
        let createDate = DateFormatter()
        createDate.dateFormat = "MM/dd HH:mm"
        createDate.locale = Locale(identifier: "ko_KR")
        
        let date = boardPost.createDate.dateValue()
        return createDate.string(from: date)
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
                              createDate: Timestamp(date: Date()))
        
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
        let sortedComments = comments.sorted {
            $0.createDate.dateValue() < $1.createDate.dateValue()
        }
        
        let userFetchers = sortedComments.map { comment in
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
    
    func getDatas(gatherings: [MyGatherings], user: LetportsUser) {
        let gatheringPublishers = gatherings.map { gathering in
            let collectionPath3: [FirestorePathComponent] = [
                .collection(.gatherings),
                .document(gathering.uid)
            ]
            return FM.getData(pathComponents: collectionPath3, type: Gathering.self)
        }
        
        Publishers.MergeMany(gatheringPublishers)
            .collect()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] allGatherings in
                guard let self = self else { return }
                let flatGatherings = allGatherings.flatMap { $0 }
            })
            .store(in: &cancellables)
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
        delegate?.presentActionSheet(post: self.boardPost, isWriter: checkBoardWriter())
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
        self.isLoading = true
        deleteBoardImages()
            .flatMap { [weak self] in
                self?.deletePostDocument() ?? Fail(error: FirestoreError.unknownError(NSError())).eraseToAnyPublisher()
            }
            .sink(receiveCompletion: {[weak self] completion in
                switch completion {
                case .finished:
                    print("게시글과 이미지 삭제 완료")
                    self?.isLoading = false
                    self?.delegate?.boardDetailBackBtnTap()
                case .failure(let error):
                    self?.isLoading = false
                    print("게시글 또는 이미지 삭제 실패: \(error.localizedDescription)")
                }
            }, receiveValue: {})
            .store(in: &cancellables)
    }
    
    func reportPost() {
        self.delegate?.presentReportAlert()
    }
    
    private func deleteBoardImages() -> AnyPublisher<Void, FirestoreError> {
        guard !boardPost.imageUrls.isEmpty else {
            return Just(()).setFailureType(to: FirestoreError.self).eraseToAnyPublisher()
        }
        
        let deletePublishers = boardPost.imageUrls.compactMap { imageUrlString in
            deleteImageFromStorage(imageUrlString: imageUrlString)
        }
        
        return Publishers.MergeMany(deletePublishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    private func deleteImageFromStorage(imageUrlString: String) -> AnyPublisher<Void, FirestoreError> {
        let storageReference = Storage.storage().reference(forURL: imageUrlString)
        
        return Future<Void, FirestoreError> { promise in
            storageReference.delete { error in
                if let error = error {
                    print("Error deleting board image: \(error.localizedDescription)")
                    promise(.failure(.unknownError(error)))
                } else {
                    print("Successfully deleted board image.")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    private func deletePostDocument() -> AnyPublisher<Void, FirestoreError> {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.board),
            .document(boardPost.postUID)
        ]
        
        return FM.deleteDocument(pathComponents: collectionPath)
            .handleEvents(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("게시글 삭제 완료")
                case .failure(let error):
                    print("게시글 삭제 실패: \(error)")
                }
            })
            .mapError { error in
                print("Firestore 삭제 오류: \(error.localizedDescription)")
                return FirestoreError.deleteFailed
            }
            .eraseToAnyPublisher()
    }
    
    
    func checkBoardWriter() -> Bool {
        let checkWriter = self.boardPost.userUID == UserManager.shared.getUserUid()
        return checkWriter
    }
    
}

