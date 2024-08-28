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

protocol GatheringDetailCoordinatorDelegate: AnyObject {
	func showBoardDetail(boardPost: Post, gathering: Gathering)
	func dismissJoinView()
	func presentActionSheet()
	func leaveGathering()
	func reportGathering()
	func showLeaveGatheringConfirmation()
	func dismissAndUpdateUI()
	func showError(message: String)
	func gatheringDetailBackBtnTap()
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
// 게시판버튼 유형
enum BoardBtnType: String {
	case all = "All"
	case noti = "Noti"
	case free = "Free"
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
	@Published var selectedBoardType: BoardBtnType = .all
	@Published var masterNickname: String = ""
	@Published var isMaster: Bool = false
	
	private let currentUser: LetportsUser
    private let currentGatheringID: String?
	private let gatheringId: String = "gathering008"
	private var cancellables = Set<AnyCancellable>()
	var updateUI: (() -> Void)?
	
	weak var delegate: GatheringDetailCoordinatorDelegate?
	
    init(currentUser: LetportsUser, currentGatheringID: String) {
		self.currentUser = currentUser
        self.currentGatheringID = currentGatheringID
		//		self.gatheringId = gatheringId
	}
	
	func loadData() {
		fetchGatheringData()
		fetchBoardData()
	}
	
	func dismissJoinView() {
		delegate?.dismissJoinView()
	}
	
	func didTapBoardCell(boardPost: Post) {
		self.delegate?.showBoardDetail(boardPost: boardPost, gathering: gathering!)
	}
	
	func showActionSheet() {
		delegate?.presentActionSheet()
	}
	
	func leaveGathering() {
		delegate?.showLeaveGatheringConfirmation()
	}
	
	func reportGathering() {
		// 신고하기 로직 구현
		print("신고하기")
	}
	
	func gatheringDetailBackBtnTap() {
		delegate?.gatheringDetailBackBtnTap()
	}
	
	
	//모임데이터
	private func fetchGatheringData() {
		FirestoreManager.shared.getDocument(collection: "Gatherings", documentId: currentGatheringID!, type: Gathering.self)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .finished:
					print("데이터 가져오기 완료")
				case .failure(let error):
					print("에러 발생: \(error)")
				}
			}, receiveValue: { [weak self] gathering in
				self?.gathering = gathering
				self?.updateMembershipStatus()
				self?.updateMasterStatus()
				self?.getMasterNickname()
				print("가져온 Gathering 객체:")
				print(gathering)
			})
			.store(in: &cancellables)
	}
	
	// 게시판데이터
	private func fetchBoardData() {
		FirestoreManager.shared.getAllDocuments(collection: "Board", type: Post.self)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .finished:
					print("게시판 데이터 가져오기 완료")
				case .failure(let error):
					print("게시판 데이터 가져오기 에러: \(error)")
				}
			}, receiveValue: { [weak self] posts in
				self?.boardData = posts
				print("가져온 Post 객체:")
				print(posts)
			})
			.store(in: &cancellables)
	}
	
	// 모임탈퇴
	func removeGatheringFromUser() -> AnyPublisher<Void, FirestoreError> {
		guard let gathering = gathering else {
			return Fail(error: FirestoreError.documentNotFound).eraseToAnyPublisher()
		}
		
		return FirestoreManager.shared.getDocument(collection: "Users", documentId: currentUser.uid, type: LetportsUser.self)
			.flatMap { user -> AnyPublisher<Void, FirestoreError> in
				var updatedMyGathering = user.myGathering
				updatedMyGathering.removeAll { $0 == gathering.gatheringUid }
				
				return FirestoreManager.shared.updateData(collection: "Users",
														  document: self.currentUser.uid,
														  fields: ["MyGathering": updatedMyGathering])
			}
			.eraseToAnyPublisher()
	}
	
	// 모임 나가기 확인
	func confirmLeaveGathering() {
		guard let gathering = gathering else {
			delegate?.showError(message: "모임 정보를 찾을 수 없습니다.")
			return
		}
		
		let removeFromUser = removeGatheringFromUser()
		let updateGathering = updateGatheringAfterLeaving(gathering: gathering)
		
		Publishers.Zip(removeFromUser, updateGathering)
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("Successfully left the gathering")
					self?.membershipStatus = .notJoined
					self?.gathering?.gatherNowMember -= 1
					self?.gathering?.gatheringMembers.removeAll { $0.userUID == self?.currentUser.uid }
					self?.delegate?.dismissAndUpdateUI()
				case .failure(let error):
					print("Error leaving gathering: \(error)")
					self?.delegate?.showError(message: "모임을 나가는데 실패했습니다: \(error.localizedDescription)")
				}
			}, receiveValue: { _ in })
			.store(in: &cancellables)
	}
	
	// 탈퇴후 업데이트
	private func updateGatheringAfterLeaving(gathering: Gathering) -> AnyPublisher<Void, FirestoreError> {
		let updatedMembers = gathering.gatheringMembers.filter { $0.userUID != currentUser.uid }
		let updatedNowMember = gathering.gatherNowMember - 1
		
		// GatheringMember 객체를 Dictionary로 변환
		let updatedMembersDicts = updatedMembers.map { member -> [String: Any] in
			return [
				"Answer": member.answer,
				"Image": member.image,
				"JoinDate": member.joinDate,
				"JoinStatus": member.joinStatus,
				"NickName": member.nickName,
				"UserUID": member.userUID,
				"SimpleInfo": member.simpleInfo
			]
		}
		
		return FirestoreManager.shared.updateData(
			collection: "Gatherings",
			document: gathering.gatheringUid,
			fields: [
				"GatheringMembers": updatedMembersDicts,
				"GatherNowMember": updatedNowMember
			]
		)
	}
	// 모임 가입
	func joinGathering(answer: String) -> AnyPublisher<Void, FirestoreError> {
		guard let gathering = gathering else {
			return Fail(error: FirestoreError.documentNotFound).eraseToAnyPublisher()
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let joinDate = dateFormatter.string(from: Date())
		
		
		let newMember: [String: Any] = [
			"Answer": answer,
			"Image": currentUser.image,
			"JoinDate": joinDate,
			"JoinStatus": "pending",
			"NickName": currentUser.nickname,
			"UserUID": currentUser.uid,
			"SimpleInfo": currentUser.simpleInfo
		]
		
		let updatedNowMember = gathering.gatherNowMember + 1
		
		return FirestoreManager.shared.updateData(
			collection: "Gatherings",
			document: gathering.gatheringUid,
			fields: [
				"GatheringMembers": FieldValue.arrayUnion([newMember]),
				"GatherNowMember": updatedNowMember
			]
		)
		.flatMap { _ in
			FirestoreManager.shared.updateData(
				collection: "Users",
				document: self.currentUser.uid,
				fields: ["MyGathering": FieldValue.arrayUnion([self.gatheringId])]
			)
		}
		.eraseToAnyPublisher()
	}
	
	// 모임장 닉네임
	private func getMasterNickname() {
		guard let gathering = self.gathering else {
			self.masterNickname = "알 수 없음"
			return
		}
		let masterUID = gathering.gatheringMaster
		let members = gathering.gatheringMembers
		
		if let masterMember = members.first(where: { $0.userUID == masterUID }) {
			self.masterNickname = masterMember.nickName
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
		guard let gathering = self.gathering else {
			self.membershipStatus = .notJoined
			print("가입중인지 아닌지: \(self.membershipStatus)")
			return
		}
		
		if let member = gathering.gatheringMembers.first(where: { $0.userUID == currentUser.uid }) {
			switch member.joinStatus {
			case "joined":
				self.membershipStatus = .joined
			case "pending":
				self.membershipStatus = .pending
			default:
				self.membershipStatus = .notJoined
			}
		}
	}
	// 모임 멤버들 정보
	func getGatheringMembers() -> [GatheringMember] {
		return gathering?.gatheringMembers ?? []
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
		return CGFloat(numberOfRows) * cellHeight
	}
	
	// 예시 사용자
	static let dummyUser = LetportsUser(
		email: "user010@example.com",
		image: "https://cdn.pixabay.com/photo/2023/08/07/19/47/water-lily-8175845_1280.jpg기",
		myGathering: ["gathering012"],
		nickname: "타이거팬",
		simpleInfo: "ㅁㅁㅁ",
		uid: "user005",
		userSports: "KBO",
		userSportsTeam: "기아 타이거즈"
	)
	
	// 게시판 분류
	var filteredBoardData: [Post] {
		switch selectedBoardType {
		case .all:
			return boardData
		case .noti, .free:
			return boardData.filter { $0.boardType == selectedBoardType.rawValue }
		}
	}
}

