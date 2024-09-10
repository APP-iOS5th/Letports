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
    case commentEmpty
    case comment(comment: Comment)
}

enum GatheringBoardError: Error {
	case boardNotFound
	case deleteBoardFailed
}

protocol GatheringBoardDetailCoordinatorDelegate: AnyObject {
    func boardDetailBackBtnTap()
	func presentActionSheet(post: Post, gathering: Gathering, isWriter: Bool)
    func presentReportAlert()
	func showError(message: String)
    func presentDeleteBoardAlert()
}

final class GatheringBoardDetailVM {
    @Published private(set) var boardPost: Post?
    @Published private(set) var commentsWithUsers: [(comment: Comment, user: LetportsUser)] = []
    @Published private(set) var isLoading: Bool = false
    
    
    private(set) var allUsers: [LetportsUser]
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: GatheringBoardDetailCoordinatorDelegate?
    private(set) var gathering: Gathering
    private(set) var postUid: String
    
    
    init(postUid: String, allUsers: [LetportsUser], gathering: Gathering) {
        self.postUid = postUid
        self.allUsers = allUsers
        self.gathering = gathering
    }
	
	private func handleError(_ error: GatheringBoardError) {
		switch error {
		case .boardNotFound:
			delegate?.showError(message: "게시글 정보를 찾을 수 없습니다")
		case .deleteBoardFailed:
			delegate?.showError(message: "게시글 삭제에 실패했습니다")
		}
	}
    
	private var cellType: [GatheringBoardDetailCellType] {
		var cellTypes: [GatheringBoardDetailCellType] = []
		cellTypes.append(.boardProfileTitle)
		cellTypes.append(.boardContents)
		cellTypes.append(.separator)
		
		if let board = self.boardPost {
			if !board.imageUrls.isEmpty {
				cellTypes.append(.images)
				cellTypes.append(.separator)
			}
		}
        
        cellTypes.append(.commentHeaderLabel)
        
        if self.commentsWithUsers.isEmpty {
            cellTypes.append(.commentEmpty)
        } else {
            for commentWithUser in self.commentsWithUsers {
                cellTypes.append(.comment(comment: commentWithUser.comment))
            }
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
		if let board = boardPost?.userUID {
			if let user = allUsers.first(where: { $0.uid == board }) {
				let result = (nickname: user.nickname, imageUrl: user.image)
				return result
			}
			return nil
		} else {
			return nil
		}
	}
    
	func getPostDate() -> String {
		let createDate = DateFormatter()
		createDate.dateFormat = "MM/dd HH:mm"
		createDate.locale = Locale(identifier: "ko_KR")
		
		if let boardCreateDate = boardPost?.createDate {
			let date = boardCreateDate.dateValue()
			return createDate.string(from: date)
		} else {
			return "날짜 없음"
		}
	}
    
	func getComment(postUid: String) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(self.gathering.gatheringUid),
            .collection(.board),
            .document(postUid),
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
			.document(self.postUid),
            .collection(.comment),
            .document(uuid)
        ]
        
		let comment = Comment(postUID: self.postUid,
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
		if let boardPost = self.boardPost {
			delegate?.presentActionSheet(post: boardPost, gathering: self.gathering, isWriter: checkBoardWriter())
		}
	}
    
    func getPost() {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.board),
            .document(postUid)
        ]
        
		FM.getData(pathComponents: collectionPath, type: Post.self)
			.sink { [weak self] completion in
				switch completion {
				case .finished:
					print("fetchBoardData 완료")
				case .failure(let error):
					print("fetchBoardData 오류:", error)
					self?.handleError(.boardNotFound)
				}
			} receiveValue: { [weak self] post in
				guard let post = post.first else {
					return
				}
				self?.boardPost = post
				self?.getComment(postUid: post.postUID)
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
		guard let boardPost = self.boardPost else {
			// boardPost가 nil인 경우 에러를 반환하거나 빈 작업을 수행
			return Fail(error: FirestoreError.unknownError("Board post is nil" as! Error))
				.eraseToAnyPublisher()
		}
		
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
			.document(self.postUid)
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
		if let userUid = self.boardPost?.userUID {
			let checkWriter = userUid == UserManager.shared.getUserUid()
			return checkWriter
		}
		else { return false }
	}
}

