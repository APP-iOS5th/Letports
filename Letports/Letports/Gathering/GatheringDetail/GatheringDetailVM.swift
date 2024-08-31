//
//  GatheringDeatilVM.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit
import Combine
import FirebaseFirestore


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
    @Published var isMaster: Bool = false
    
    private let currentUser: LetportsUser
    private var currentGatheringUid: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: GatheringDetailCoordinatorDelegate?
    
    init(currentUser: LetportsUser, currentGatheringUid: String) {
        self.currentUser = currentUser
        self.currentGatheringUid = currentGatheringUid
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
    
    func showGatherSettingView() {
        guard let gatheringUid = gathering?.gatheringUid else { return }
        self.delegate?.pushGatherSettingView(gathering: gatheringUid)
    }
    
    func loadData() {
        fetchGatheringData()
        fetchBoardData()
    }
    
    func didTapBoardCell(boardPost: Post) {
        guard let gathering = self.gathering else { return }
        self.delegate?.pushBoardDetail(gathering: gathering, boardPost: boardPost, allUsers: self.allUsers)
    }
    
    func didTapProfile(member: LetportsUser) {
        self.delegate?.pushProfileView(member: member)
    }
    
    func showActionSheet() {
        delegate?.presentActionSheet()
    }
    
    func leaveGathering() {
        delegate?.presentLeaveGatheringConfirmation()
    }
    
    func reportGathering() {
        // 신고하기 로직 구현
        print("신고하기")
    }
    
    func gatheringDetailBackBtnTap() {
        delegate?.gatheringDetailBackBtnTap()
    }
    
    func didTapUploadBtn(type: PostType) {
        guard let gathering = self.gathering else { return }
        self.delegate?.pushPostUploadViewController(type: type, gathering: gathering)
    }
    
    func pushGatherSettingView() {
        
    }
    
    //모임데이터
    private func fetchGatheringData() {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid)
        ]
        print("currentGatheringUid", currentGatheringUid)
        FM.getData(pathComponents: collectionPath, type: Gathering.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("fetchGatheringData Finish")
                case .failure(let error):
                    print("fetchGatheringData Error1", error)
                }
            } receiveValue: { [weak self] gathering in
                self?.gathering = gathering.first
                self?.fetchGatheringMemberData()
                self?.updateMasterStatus()
            }
            .store(in: &cancellables)
    }
    
    // 모임멤버데이터
    private func fetchGatheringMemberData() {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.gatheringMembers)
        ]
        
        FM.getData(pathComponents: collectionPath, type: GatheringMember.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("fetchGatheringData Finish")
                case .failure(let error):
                    print("fetchGatheringData Error2", error)
                }
            } receiveValue: { [weak self] member in
                self?.member = member
                self?.updateMembershipStatus()
                self?.filteringData(memberUids: member)
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
                print("전체 사용자 수:", self.allUsers.count)
                print("모임 멤버 수:", self.memberData.count)
            }
            .store(in: &cancellables)
    }
    
    // 게시글
    private func fetchBoardData() {
        let boardCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.board)
        ]
        
        FM.getData(pathComponents: boardCollectionPath, type: Post.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("fetchBoardData 완료")
                case .failure(let error):
                    print("fetchBoardData 오류:", error)
                }
            } receiveValue: { [weak self] posts in
                
                let sortedPosts = posts.sorted { $0.createDate.dateValue() > $1.createDate.dateValue() }
                
                self?.boardData = sortedPosts
            }
            .store(in: &cancellables)
    }
    
    // 모임장 닉네임
    private func getMasterNickname() {
        guard let gathering = self.gathering else {
            self.masterNickname = "알 수 없음"
            return
        }
        let masterUID = gathering.gatheringMaster
        let members = self.memberData
        
        if let masterMember = members.first(where: { $0.uid == masterUID }) {
            self.masterNickname = masterMember.nickname
        } else {
            self.masterNickname = "알 수 없음"
        }
    }
    // 모임장 상태인지
    private func updateMasterStatus() {
        guard let gathering = self.gathering else {
            isMaster = false
            return
        }
        
        let gatheringMaster = gathering.gatheringMaster
        isMaster = currentUser.uid == gatheringMaster
    }
    // 현재 사용자 정보
    func getCurrentUserInfo() -> LetportsUser {
        print("현재 사용자 정보: \(currentUser)")
        return currentUser
    }
    // 가입중인지 아닌지
    private func updateMembershipStatus() {
        let gathering = self.member
        self.membershipStatus = .notJoined
        if let member = gathering.filter({ $0.userUID == currentUser.uid }).first {
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
    // 모임 멤버들 정보
    func getGatheringMembers() -> [LetportsUser] {
        return self.memberData
    }
    // 모임 가입
    func joinGathering(answer: String) -> AnyPublisher<Void, FirestoreError> {
        
        // nowMember 추가
        let joinCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid)
        ]
        
        if var gathering = gathering {
            gathering.gatherNowMember += 1
        }
        
        let updatedGatheringDicts: [String: Any] = [
            "GatherNowMember": gathering?.gatherNowMember as Any
        ]
        
        // GatheringMember 추가
        let addMemberCollectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.gatheringMembers),
            .document(currentUser.uid)
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let joinDate = dateFormatter.string(from: Date())
        
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
        return Publishers.Zip3(
            FM.updateData(pathComponents: joinCollectionPath, fields: updatedGatheringDicts),
            FM.setData(pathComponents: addMemberCollectionPath, data: newMemberDict),
            FM.setData(pathComponents: userMyGatheringPath, data: myGathering)
        )
        .map { _, _, _ in () }
        .eraseToAnyPublisher()
    }
    
    // 모임탈퇴
    func removeGatheringFromUser() -> AnyPublisher<Void, FirestoreError> {
        // Gathering에서 멤버 제거
        let collectionPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid),
            .collection(.gatheringMembers),
            .document(currentUser.uid)
        ]
        
        // 현재 인원 수 감소
        let gatheringPath: [FirestorePathComponent] = [
            .collection(.gatherings),
            .document(currentGatheringUid)
        ]
        
        if var gathering = gathering {
            gathering.gatherNowMember -= 1
        }
        
        let updatedGatheringDicts: [String: Any] = [
            "GatherNowMember": gathering?.gatherNowMember as Any
        ]
        
        // 유저의 MyGatherings에서 제거
        let userMyGatheringPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(currentUser.uid),
            .collection(.myGathering),
            .document(currentGatheringUid)
        ]
        
        // 모든 업데이트를 동시에 실행
        return Publishers.Zip3(
            FM.deleteDocument(pathComponents: collectionPath),
            FM.updateData(pathComponents: gatheringPath, fields: updatedGatheringDicts),
            FM.deleteDocument(pathComponents: userMyGatheringPath)
        )
        .map { _, _, _ in () }
        .eraseToAnyPublisher()
    }
    
    // 모임 나가기 확인
    func confirmLeaveGathering() {
        guard gathering != nil else {
            delegate?.showError(message: "모임 정보를 찾을 수 없습니다.")
            return
        }
        removeGatheringFromUser()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("모임 탈퇴 완료")
                    self.loadData() // 데이터 새로고침
                case .failure(let error):
                    print("모임 탈퇴 실패: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
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
        let cellHeight: CGFloat = 70 + 12
        let calculatedHeight = CGFloat(numberOfRows) * cellHeight
        
        // 기본 높이를 328으로 설정하고, 계산된 높이가 328을 초과할 경우에만 그 값을 반환
        return max(328, calculatedHeight)
    }
    
    // 예시 사용자
    static let dummyUser = LetportsUser(
        email: "user010@example.com",
        image: "https://cdn.pixabay.com/photo/2023/08/07/19/47/water-lily-8175845_1280.jpg",
        nickname: "투구천재",
        simpleInfo: "ㅁㅁㅁ",
        uid: "users002",
        userSports: "KBO",
        userSportsTeam: "기아 타이거즈"
    )
}

