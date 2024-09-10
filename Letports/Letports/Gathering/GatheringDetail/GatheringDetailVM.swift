//
//  GatheringDeatilVM.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit
import Combine
import FirebaseFirestore
import FirebaseStorage

// 게시판 버튼
protocol ButtonStateDelegate: AnyObject {
    func didChangeButtonState(_ button: UIButton, isSelected: Bool)
}

enum GatheringDetailCellType {
    case gatheringImage
    case gatheringTitle
    case gatheringInfo
    case gatheringProfile
    case currentMemLabel
    case boardButtonType
    case gatheringBoard
    case separator
}

enum GatheringError: Error {
    case gatheringNotFound
    case leaveFailed
    case cancelWaitingFailed
}

// 가입상태
enum MembershipStatus {
    case notJoined
    case pending
    case joined
}


class GatheringDetailVM {
    @Published private(set) var gathering: Gathering?
    @Published private(set) var membershipStatus: MembershipStatus = .joined
    @Published private(set) var boardData: [Post] = []
    @Published private(set) var joinedMembers: [GatheringMember] = []
    @Published private(set) var allUsers: [LetportsUser] = []
    @Published private(set) var member: [GatheringMember] = []
    @Published private(set) var memberData: [LetportsUser] = []
    @Published var selectedBoardType: PostType = .all
    @Published var masterNickname: String = ""
    @Published var teamColor: String?
    @Published var isMaster: Bool = false
    @Published var isLoading: Bool = false
    
    private let currentUser: LetportsUser
    private let currentGatheringUid: String
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: GatheringDetailCoordinatorDelegate?
    
    init(currentUser: LetportsUser, currentGatheringUid: String, teamColor: String) {
        self.currentUser = currentUser
        self.currentGatheringUid = currentGatheringUid
        self.teamColor = teamColor
        self.loadData()
    }
    
    // 게시판 분류
    var filteredBoardData: [Post] {
        switch selectedBoardType {
        case .all:
            return boardData
        case .noti, .free:
            return boardData.filter { $0.boardType.rawValue == selectedBoardType.rawValue }
        }
    }
    
    func pushGatherSettingView() {
        guard let gathering = gathering else { return }
        self.delegate?.pushGatherSettingView(gatheringUid: gathering.gatheringUid)
    }
    
    func loadData() {
        self.isLoading = true
        fetchAllData()
    }
    
    func didTapBoardCell(boardPost: Post) {
        guard let gathering = self.gathering else { return }
        self.delegate?.pushBoardDetail(gathering: gathering, boardPost: boardPost, allUsers: self.allUsers)
    }
    
    func didTapProfile(member: LetportsUser) {
        self.delegate?.pushProfileView(member: member)
    }
    
    func presentActionSheet() {
        delegate?.presentActionSheet()
    }
    
    func showGatheringEditView() {
        guard let gathering = gathering else { return }
        self.delegate?.pushGatheringEditView(gathering: gathering)
    }
    
    func leaveGathering() {
        delegate?.presentLeaveGatheringConfirmation()
    }
    
    func reportGathering() {
        delegate?.presentReportConfirmView()
    }
    
    func gatheringDetailBackBtnTap() {
        delegate?.gatheringDetailBackBtnTap()
    }
    
    func didTapUploadBtn(type: PostType) {
        guard let gathering = self.gathering else { return }
        self.delegate?.pushPostUploadViewController(type: type, gathering: gathering)
    }
    
    private func handleError(_ error: GatheringError) {
        switch error {
        case .gatheringNotFound:
            delegate?.showError(message: "모임 정보를 찾을 수 없습니다")
        case .leaveFailed:
            delegate?.showError(message: "모임 탈퇴에 실패했습니다")
        case .cancelWaitingFailed:
            delegate?.showError(message: "가입 대기 취소에 실패했습니다")
        }
    }
    
    //모임데이터 && 게시글 && 모임멤버데이터
    private func fetchAllData() {
        let gatheringCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid)
        ]
        
        let boardCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.board)
        ]
        
        let memberCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.gatheringMembers)
        ]
        
        let gatheringPublisher = FM.getData(pathComponents: gatheringCollectionPath, type: Gathering.self)
        let boardPublisher = FM.getData(pathComponents: boardCollectionPath, type: Post.self)
        let memberPublisher = FM.getData(pathComponents: memberCollectionPath, type: GatheringMember.self)
        
        Publishers.CombineLatest3(gatheringPublisher, boardPublisher, memberPublisher)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("fetchAllData 완료")
                    self?.isLoading = false
                case .failure(let error):
                    print("fetchAllData 오류:", error)
                    self?.isLoading = false
                    self?.handleError(.gatheringNotFound)
                }
            } receiveValue: { [weak self] gathering, posts, members in
                self?.gathering = gathering.first
                self?.boardData = self?.sortPosts(posts) ?? []
                
                self?.member = members
                self?.updateMembershipStatus()
                self?.filteringData(memberUids: members)
                
                self?.updateMasterStatus()
            }
            .store(in: &cancellables)
    }
    
    private func filteringData(memberUids: [GatheringMember]) {
        self.joinedMembers = memberUids.filter { $0.joinStatus == "joined" }
        self.fetchGatheringUserData(memberUids: self.joinedMembers)
    }
    
    // 유저정보
    private func fetchGatheringUserData(memberUids: [GatheringMember]) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user)
        ]
        
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("fetchGatheringData Finish")
                case .failure(let error):
                    print("fetchGatheringData Error3", error)
                }
            } receiveValue: { [weak self] users in
                guard let self = self else { return }
                
                // 모든 사용자 정보 저장
                self.allUsers = users
                
                // 모임 멤버 정보 필터링
                self.memberData = users.filter { user in
                    memberUids.contains { member in
                        user.uid == member.userUID
                    }
                }
                self.getMasterNickname()
            }
            .store(in: &cancellables)
    }
    
    // 게시글 정렬
    private func sortPosts(_ posts: [Post]) -> [Post] {
        let notices = posts.filter { $0.boardType == .noti }
        let freePosts = posts.filter { $0.boardType == .free }
        
        let sortedNotices = notices.sorted { $0.createDate.dateValue() > $1.createDate.dateValue() }
        let sortedFreePosts = freePosts.sorted { $0.createDate.dateValue() > $1.createDate.dateValue() }
        
        return sortedNotices + sortedFreePosts
    }
    
    
    // 모임장 닉네임
    private func getMasterNickname() {
        guard let gathering = self.gathering else {
            self.masterNickname = "알 수 없음"
            return
        }
        let masterUID = gathering.gatheringMaster
        let members = self.memberData
        let masterMember = members.filter { $0.uid == masterUID }
        if let masterMember = masterMember.first?.nickname {
            self.masterNickname = masterMember
        }
    }
    // 모임장 상태인지 (가입중인지 아닌지와 합치는걸로)
    private func updateMasterStatus() {
        guard let gathering = self.gathering else {
            isMaster = false
            return
        }
        
        let gatheringMaster = gathering.gatheringMaster
        isMaster = currentUser.uid == gatheringMaster
    }
    
    // 가입중인지 아닌지
    private func updateMembershipStatus() {
        let gathering = self.member
        if let member = gathering.first(where: { $0.userUID == currentUser.uid }) {
            switch member.joinStatus {
            case "joined":
                self.membershipStatus = .joined
            case "pending":
                self.membershipStatus = .pending
            default:
                self.membershipStatus = .notJoined
            }
        } else {
            // 사용자가 모임 멤버 목록에 없는 경우
            self.membershipStatus = .notJoined
        }
    }
    
    // 현재 사용자 정보
    func getCurrentUserInfo() -> LetportsUser {
        return currentUser
    }
    // 모임 멤버들 정보
    func getGatheringMembers() -> [LetportsUser] {
        return self.memberData
    }
    // 모임 가입
    func joinGathering(answer: String) -> AnyPublisher<Void, FirestoreError> {
        
        // GatheringMember 추가
        let addMemberCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.gatheringMembers),
            .document(currentUser.uid)
        ]
        
        let joinDate = Date().toString(format: "yyyy-MM-dd")
        
        let newMemberDict = GatheringMember(
            answer: answer,
            joinDate: joinDate,
            joinStatus: "pending",
            userUID: currentUser.uid
        )
        // MyGatherings 추가
        let userMyGatheringPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(currentUser.uid),
            .collection(.myGathering),
            .document(currentGatheringUid)
        ]
        
        let myGathering = MyGatherings(uid: currentGatheringUid)
        
        // 모든 업데이트를 동시에 실행
        return Publishers.Zip(
            FM.setData(pathComponents: addMemberCollectionPath, data: newMemberDict),
            FM.setData(pathComponents: userMyGatheringPath, data: myGathering)
        )
        .map { _, _ in () }
        .eraseToAnyPublisher()
    }
    
    func confirmRemoveGatheringFromUser() {
        removeGatheringFromUser()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.loadData()
                    print("모임 탈퇴 완료 및 알림 발송 완료")
                case .failure(let error):
                    print("모임 탈퇴 중 오류 발생: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func removeGatheringFromUser() -> AnyPublisher<Void, FirestoreError> {
        guard let gathering = gathering else {
            return Fail(error: .documentNotFound).eraseToAnyPublisher()
        }

        let gatheringMemberPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.gatheringMembers),
            .document(currentUser.uid)
        ]
        
        let userMyGatheringPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(currentUser.uid),
            .collection(.myGathering),
            .document(currentGatheringUid)
        ]
        
        let boardPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.board)
        ]
        
        let updatePath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
        ]
        
        let newNowMember = max(gathering.gatherNowMember - 1, 0)
        let updateGatheringMemberField: [String: Any] = ["GatherNowMember": newNowMember]
        
        // 게시글 및 이미지 삭제 후 진행
        return deleteUserPostsAndImages(for: boardPath)
            .flatMap {
                FM.deleteDocument(pathComponents: gatheringMemberPath)
            }
            .flatMap {
                FM.deleteDocument(pathComponents: userMyGatheringPath)
            }
            .flatMap {
                FM.updateData(pathComponents:updatePath, fields: updateGatheringMemberField)
            }
            .flatMap {
                NotificationService.shared.sendPushNotificationByUID(
                    uid: gathering.gatheringMaster,
                    title: "모임 탈퇴",
                    body: "\(self.currentUser.nickname)님이 \(gathering.gatherName)모임에서 탈퇴하셨습니다."
                )
            }
            .eraseToAnyPublisher()
    }

    private func deleteUserPostsAndImages(for boardPath: [FirestorePathComponent]) -> AnyPublisher<Void, FirestoreError> {
        return FM.getData(pathComponents: boardPath, type: Post.self)
            .flatMap { posts -> AnyPublisher<Void, FirestoreError> in
                let userPosts = posts.filter { $0.userUID == self.currentUser.uid }
                
                // 게시글 이미지 삭제
                let deleteImagesPublisher = self.deleteBoardImages(for: userPosts)
                
                // 게시글 삭제
                let deletePostsPublisher = self.deleteBoardPosts(for: userPosts)
                
                // 두 작업을 순차적으로 실행
                return deleteImagesPublisher
                    .flatMap { _ in
                        deletePostsPublisher
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // 게시글의 이미지 삭제
    private func deleteBoardImages(for posts: [Post]) -> AnyPublisher<Void, FirestoreError> {
        let deleteImagePublishers = posts.flatMap { post in
            post.imageUrls.compactMap { imageUrl in
                let storageRef = Storage.storage().reference(forURL: imageUrl)
                return Future<Void, FirestoreError> { promise in
                    storageRef.delete { error in
                        if let error = error {
                            promise(.failure(.unknownError(error)))
                        } else {
                            promise(.success(()))
                        }
                    }
                }.eraseToAnyPublisher()
            }
        }
        return Publishers.MergeMany(deleteImagePublishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    // 게시글 삭제
    private func deleteBoardPosts(for posts: [Post]) -> AnyPublisher<Void, FirestoreError> {
        let deletePostPublishers = posts.map { post in
            let postPath: [FirestorePathComponent] = [
                .collection(.gatherings),
                .document(currentGatheringUid),
                .collection(.board),
                .document(post.postUID)
            ]
            return FM.deleteDocument(pathComponents: postPath)
        }
        return Publishers.MergeMany(deletePostPublishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    func confirmCancelWaiting() {
        guard let gathering = gathering else {
            handleError(.gatheringNotFound)
            return
        }

        removeWaitingRegist()
            .flatMap { [weak self] _ -> AnyPublisher<Void, FirestoreError> in
                guard let self = self else {
                    return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "self가 해제되었습니다."])))
                        .eraseToAnyPublisher()
                }

                let gatheringMaster = gathering.gatheringMaster
                let gatherName = gathering.gatherName
                let nickname = UserManager.shared.currentUser?.nickname ?? "알 수 없는 사용자"

                return NotificationService.shared.sendPushNotificationByUID(
                    uid: gatheringMaster,
                    title: "가입신청 취소",
                    body: "\(nickname)님이 \(gatherName)모임에서 가입 신청을 취소하셨습니다."
                )
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("가입 대기 취소 완료 및 알림 발송 완료")
                    self.loadData()
                case .failure(_):
                    self.handleError(.cancelWaitingFailed)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // 가입 대기 취소
    func removeWaitingRegist() -> AnyPublisher<Void, FirestoreError> {
        // Gathering에서 멤버 제거
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.gatheringMembers),
            .document(currentUser.uid)
        ]
        
        // 유저의 MyGatherings에서 제거
        let userMyGatheringPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(currentUser.uid),
            .collection(.myGathering),
            .document(currentGatheringUid)
        ]
        
        // 모든 업데이트를 동시에 실행
        return Publishers.Zip(
            FM.deleteDocument(pathComponents: collectionPath),
            FM.deleteDocument(pathComponents: userMyGatheringPath)
        )
        .map { _, _ in () }
        .eraseToAnyPublisher()
    }


    private var cellType: [GatheringDetailCellType] {
        var cellTypes: [GatheringDetailCellType] = []
        cellTypes.append(.gatheringImage)
        cellTypes.append(.gatheringTitle)
        cellTypes.append(.separator)
        cellTypes.append(.gatheringInfo)
        cellTypes.append(.currentMemLabel)
        cellTypes.append(.gatheringProfile)
        cellTypes.append(.separator)
        cellTypes.append(.boardButtonType)
        cellTypes.append(.separator)
        cellTypes.append(.gatheringBoard)
        return cellTypes
    }
    
    func getDetailCellCount() -> Int {
        return self.cellType.count
    }
    
    func getDetailCellTypes() -> [GatheringDetailCellType] {
        return self.cellType
    }
    // 게시판 높이계산
    func calculateBoardHeight() -> CGFloat {
        let numberOfRows = filteredBoardData.count
        let cellHeight: CGFloat = 50 + 12
        let calculatedHeight = CGFloat(numberOfRows) * cellHeight
        
        // 기본 높이를 328으로 설정하고, 계산된 높이가 328을 초과할 경우에만 그 값을 반환
        return max(328, calculatedHeight)
    }
}

