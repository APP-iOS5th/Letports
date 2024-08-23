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
enum BoardButtonType: String {
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
	@Published var selectedBoardType: BoardButtonType = .all
	@Published var masterNickname: String = ""
	@Published var isMaster: Bool = false
	
	private let currentUser: LetportsUser
	private var cancellables = Set<AnyCancellable>()
	var updateUI: (() -> Void)?
	
	weak var coordinatorDelegate: GatheringDetailCoordinatorDelegate?
	
	init(currentUser: LetportsUser) {
		self.currentUser = currentUser
	}
	
	func loadData() {
		fetchGatheringData()
		fetchBoardData()
	}
	
	func dismissJoinView() {
			coordinatorDelegate?.dismissJoinView()
		}
	
	func didTapBoardCell(boardPost: Post) {
		self.coordinatorDelegate?.showBoardDetail(boardPost: boardPost, gathering: gathering!)
	}
	
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
	
	private func fetchGatheringData() {
		FirestoreManager.shared.getDocument(collection: "Gatherings", documentId: "gathering012", type: Gathering.self)
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
		return currentUser
	}
	// 가입중인지 아닌지
	private func updateMembershipStatus() {
		guard let gathering = self.gathering else {
			self.membershipStatus = .notJoined
			return
		}
		
		if currentUser.myGathering.contains(gathering.gatheringUid) {
			self.membershipStatus = .joined
		} else {
			self.membershipStatus = .notJoined
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
	
	func calculateBoardHeight() -> CGFloat {
		let numberOfRows = filteredBoardData.count
		let cellHeight: CGFloat = 50 + 12
		return CGFloat(numberOfRows) * cellHeight
	}
	
	// 예시 사용자
	static let dummyUser = LetportsUser(
		 email: "user005@example.com",
		 image: "https://cdn.pixabay.com/photo/2023/08/07/19/47/water-lily-8175845_1280.jpg",
		 myGathering: ["gathering012"],
		 nickname: "완벽수비",
		 simpleInfo: "빠른 속도를 좋아합니다",
		 uid: "user015",
		 userSports: "KBO",
		 userSportsTeam: "두산 베어스"
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

