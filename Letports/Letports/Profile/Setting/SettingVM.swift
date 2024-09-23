//
//  SettingVM.swift
//  Letports
//
//  Created by mosi on 9/3/24.
//

import Foundation
import Combine
import FirebaseStorage
import FirebaseAuth

struct AuthDeleteError: Codable {
    var userUid: String
    var errorDescription: String
    
    enum CodingKeys: String, CodingKey {
        case userUid = "UserUID"
        case errorDescription = "ErrorDescription"
    }
}

enum SettingCellType {
    case notification
    case appTermsofService
    case personnalInfo
    case openLibrary
    case appInfo
    case logout
    case exit
}

class SettingVM {
    
    private var cellType: [SettingCellType] {
        var cellTypes: [SettingCellType] = []
        cellTypes.append(.notification)
        cellTypes.append(.appTermsofService)
        cellTypes.append(.personnalInfo)
        cellTypes.append(.openLibrary)
        cellTypes.append(.appInfo)
        cellTypes.append(.logout)
        cellTypes.append(.exit)
        return cellTypes
    }
    
    private let sections: [[SettingCellType]] = [
        [.notification ],
        [.appTermsofService, .personnalInfo, .openLibrary, .appInfo],
        [.logout, .exit]
    ]
    
    weak var delegate: SettingCoordinatorDelegate?
    var notificationToggleState: Bool = false
    @Published private(set) var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func getCellTypes() -> [SettingCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func getSectionCount() -> Int {
        return sections.count
    }
    
    func getRowCount(for section: Int) -> Int {
        return sections[section].count
    }
    
    func getCellType(for indexPath: IndexPath) -> SettingCellType {
        return sections[indexPath.section][indexPath.row]
    }
    
    func getSectionTitle(for section: Int) -> String? {
        switch section {
        case 0:
            return "설정"
        case 1:
            return "앱 정보"
        case 2:
            return "유저"
        default:
            return nil
        }
    }
    
    func backToProfile() {
        delegate?.backToProfile()
    }
    
    func logout() {
        delegate?.logoutDidTap()
    }
    
    func buttonAction(cellType: SettingCellType) {
        switch cellType {
        case .appTermsofService:
            delegate?.presentBottomSheet(with: URL(string:"https://letports.notion.site/986a0cfb61584890a4bd512a87ac268a?pvs=4")!)
        case .personnalInfo:
            delegate?.presentBottomSheet(with: URL(string:"https://letports.notion.site/a55bf0b1971d43658ac4a2d626524f10?pvs=4")!)
        case .openLibrary:
            delegate?.openLibraryDidTap()
        default:
            break
        }
    }
    
    //MARK: - User Delete Method
    func exit() {
        self.isLoading = true
        
        deleteAccountAndData()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                    self?.delegate?.backToAuthView()
                case .failure(let error):
                    self?.isLoading = false
                    self?.authDeleteError(errorStr: error.localizedDescription)
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    
    func deleteAccountAndData() -> AnyPublisher<Void, FirestoreError> {
        deleteGatheringMembers()
            .flatMap { self.deleteMyGatheringBoard() }
            .flatMap { self.deleteUserDocument() }
            .flatMap { self.deleteFirebaseUser() }
            .eraseToAnyPublisher()
    }
    
    func deleteGatheringMembers() -> AnyPublisher<Void, FirestoreError> {
        let collectionPath: [FirestorePathComponent] = [.collection(.gatherings)]
        
        return FM.getData(pathComponents: collectionPath, type: Gathering.self)
            .flatMap { gatherings in
                let deletePublishers = gatherings.map { gathering in
                    self.deleteMembers(from: gathering.gatheringUid)
                }
                return Publishers.MergeMany(deletePublishers)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteMembers(from gatheringUid: String) -> AnyPublisher<Void, FirestoreError> {
        let gatheringPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gatheringUid),
            .collection(.gatheringMembers)
        ]
        
        return FM.getData(pathComponents: gatheringPath, type: GatheringMember.self)
            .flatMap { members in
                let deleteTasks = members
                    .filter { $0.userUID == UserManager.shared.getUserUid() }
                    .map { member in
                        let memberPath: [FirestorePathComponent] = [
                            .collection(.gatherings),
                            .document(gatheringUid),
                            .collection(.gatheringMembers),
                            .document(member.userUID)
                        ]
                        return FM.deleteDocument(pathComponents: memberPath)
                    }
                return Publishers.MergeMany(deleteTasks)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteMyGatheringBoard() -> AnyPublisher<Void, FirestoreError> {
        let collectionPath: [FirestorePathComponent] = [.collection(.gatherings)]
        
        return FM.getData(pathComponents: collectionPath, type: Gathering.self)
            .flatMap { gatherings in
                let deletePublishers = gatherings
                    .filter { $0.gatheringMaster == UserManager.shared.getUserUid() }
                    .map { gathering in
                        self.deleteGatheringAndRelatedData(from: gathering)
                            .flatMap {
                                self.deleteGatheringUserMyGatherings(gathering: gathering)
                            }
                    }
                return Publishers.MergeMany(deletePublishers)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteGatheringUserMyGatherings(gathering: Gathering) -> AnyPublisher<Void, FirestoreError> {
        let userCollectionPath: [FirestorePathComponent] = [.collection(.user)]
        
        return FM.getData(pathComponents: userCollectionPath, type: LetportsUser.self)
            .flatMap { users in
                
                let deleteTasks = users.map { user in
                    let myGatheringPath: [FirestorePathComponent] = [
                        .collection(.user),
                        .document(user.uid),
                        .collection(.myGathering)
                    ]
                    
                    return FM.getData(pathComponents: myGatheringPath, type: MyGatherings.self)
                        .flatMap { myGatherings -> AnyPublisher<Void, FirestoreError> in
                            let deleteMyGatheringTasks = myGatherings
                                .filter { $0.uid == gathering.gatheringUid }
                                .map { myGathering in
                                    let gatheringDocPath: [FirestorePathComponent] = [
                                        .collection(.user),
                                        .document(user.uid),
                                        .collection(.myGathering),
                                        .document(myGathering.uid)
                                    ]
                                    return FM.deleteDocument(pathComponents: gatheringDocPath)
                                }
                            return Publishers.MergeMany(deleteMyGatheringTasks)
                                .collect()
                                .map { _ in () }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                return Publishers.MergeMany(deleteTasks)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteGatheringAndRelatedData(from gathering: Gathering) -> AnyPublisher<Void, FirestoreError> {
        let boardPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.board)
        ]
        
        let gatheringMembersPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(gathering.gatheringUid),
            .collection(.gatheringMembers)
        ]
        
        let boardDeletion = FM.getData(pathComponents: boardPath, type: Post.self)
            .flatMap { boards in
                let deleteTasks = boards.map { board in
                    self.deleteImagesAndPost(from: board, gatheringUid: gathering.gatheringUid)
                }
                return Publishers.MergeMany(deleteTasks)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let gatheringMembersDeletion = FM.getData(pathComponents: gatheringMembersPath, type: GatheringMember.self)
            .flatMap { members in
                let deleteTasks = members.map { member in
                    let memberDocPath: [FirestorePathComponent] = [
                        .collection(.gatherings),
                        .document(gathering.gatheringUid),
                        .collection(.gatheringMembers),
                        .document(member.userUID)
                    ]
                    return FM.deleteDocument(pathComponents: memberDocPath)
                }
                return Publishers.MergeMany(deleteTasks)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let gatherImageDeletion = deleteImageFromStorage(imageUrlString: gathering.gatherImage)
        
        return boardDeletion
            .merge(with: gatheringMembersDeletion)
            .merge(with: gatherImageDeletion)
            .flatMap {
                let gatheringDocPath: [FirestorePathComponent] = [
                    .collection(.gatherings),
                    .document(gathering.gatheringUid)
                ]
                return FM.deleteDocument(pathComponents: gatheringDocPath)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteImagesAndPost(from board: Post, gatheringUid: String) -> AnyPublisher<Void, FirestoreError> {
        let imageDeletionTasks = board.imageUrls.map { deleteImageFromStorage(imageUrlString: $0) }
        
        return Publishers.MergeMany(imageDeletionTasks)
            .collect()
            .flatMap {_ in
                let boardDocPath: [FirestorePathComponent] = [
                    .collection(.gatherings),
                    .document(gatheringUid),
                    .collection(.board),
                    .document(board.postUID)
                ]
                return FM.deleteDocument(pathComponents: boardDocPath)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteUserDocument() -> AnyPublisher<Void, FirestoreError> {
        let userUID = UserManager.shared.getUserUid()
        let userPath: [FirestorePathComponent] = [.collection(.user), .document(userUID)]
        let myGatheringPath: [FirestorePathComponent] = [.collection(.user), .document(userUID), .collection(.myGathering)]
        let tokenPath: [FirestorePathComponent] = [.collection(.token), .document(userUID)]
        
        return FM.getData(pathComponents: userPath, type: LetportsUser.self)
            .flatMap { user -> AnyPublisher<Void, FirestoreError> in
                
                let googleProfileImageUrl = Auth.auth().currentUser?.photoURL?.absoluteString ?? ""
                let defaultImageUrl = "https://firebasestorage.googleapis.com/v0/b/letports-81f7f.appspot.com/o/Base_User_Image%2Fimage3x.png?alt=media&token=d50b63ef-70b1-42ac-8d3d-4aeb6df9e94a"
                let userImageUrl = user.first?.image ?? ""

                let deleteUserImage: AnyPublisher<Void, FirestoreError> = {
                    if userImageUrl != defaultImageUrl && userImageUrl != googleProfileImageUrl {
                        return self.deleteImageFromStorage(imageUrlString: userImageUrl)
                    } else {
                        return Just(())
                            .setFailureType(to: FirestoreError.self)
                            .eraseToAnyPublisher()
                    }
                }()
                
                // Token 문서 삭제
                return deleteUserImage
                    .flatMap { _ in
                        FM.deleteDocument(pathComponents: tokenPath)
                    }
                    // MyGathering 컬렉션에서 소모임 문서 삭제
                    .flatMap { _ in
                        FM.getData(pathComponents: myGatheringPath, type: MyGatherings.self)
                    }
                    .flatMap { myGatherings in
                        let deleteTasks = myGatherings.map { gathering in
                            let gatheringDocPath: [FirestorePathComponent] = [
                                .collection(.user),
                                .document(userUID),
                                .collection(.myGathering),
                                .document(gathering.uid)
                            ]
                            return FM.deleteDocument(pathComponents: gatheringDocPath)
                        }
                        return Publishers.MergeMany(deleteTasks)
                            .collect()
                            .eraseToAnyPublisher()
                    }
                    // 마지막으로 User 문서 삭제
                    .flatMap { _ in
                        FM.deleteDocument(pathComponents: userPath)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteFirebaseUser() -> AnyPublisher<Void, FirestoreError> {
        return Future<Void, FirestoreError> { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(.unknownError(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User is not logged in"]))))
                return
            }
            
            user.delete { error in
                if let error = error {
                    promise(.failure(.unknownError(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func authDeleteError(errorStr: String) {
        let userUid = UserManager.shared.getUserUid()
        let collectionPath: [FirestorePathComponent] = [.collection(.authDeleteError)]
        let errorModel = AuthDeleteError(userUid: userUid, errorDescription: errorStr)
        
        FM.setData(pathComponents: collectionPath, data: errorModel)
            .sink { [weak self] _ in
                self?.delegate?.backToAuthView()
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    private func deleteImageFromStorage(imageUrlString: String) -> AnyPublisher<Void, FirestoreError> {
        let storageReference = Storage.storage().reference(forURL: imageUrlString)
        
        return Future<Void, FirestoreError> { promise in
            storageReference.delete { error in
                if let error = error {
                    print("Error deleting image: \(error.localizedDescription)")
                    promise(.failure(.unknownError(error)))
                } else {
                    print("Successfully deleted image.")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
