//
//  GatheringDeatilVM.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit
import Combine
import FirebaseFirestore


protocol FirebaseServiceProtocol {
	func fetchGatheringData(gatheringUid: String) -> AnyPublisher<Gathering, Error>
}

class FirebaseService: FirebaseServiceProtocol {
	func fetchGatheringData(gatheringUid: String) -> AnyPublisher<Gathering, Error> {
		return Future { promise in
			let db = Firestore.firestore()
			let docRef = db.collection("Gatherings").document(gatheringUid)
			
			docRef.getDocument { (document, error) in
				if let error = error {
					print("Error fetching document: \(error)")
					promise(.failure(error))
					return
				}
				
				guard let document = document, document.exists else {
					print("Document does not exist")
					promise(.failure(NSError(domain: "Firestore",
											 code: -1,
											 userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
					return
				}
				
				let data = document.data()
				
				// 데이터 출력
				print("Fetched Data:")
				print(data ?? [:])
				
				let gatherImage = data?["GatherImage"] as? String
				let gatherName = data?["GatherName"] as? String
				let gatherMaxMember = data?["GatherMaxMember"] as? Int
				let gatherInfo = data?["GatherInfo"] as? String
				let gatheringCreateDate = data?["GatheringCreateDate"] as? String
				let gatheringMaster = data?["GatheringMaster"] as? String
				let gatheringUid = document.documentID
				
				// GatheringMembers 데이터 파싱
				var gatheringMembers: [GatheringMember] = []
				if let membersData = data?["GatheringMembers"] as? [[String: Any]] {
					for memberData in membersData {
						let member = GatheringMember(
							answer: memberData["Answer"] as? String ?? "",
							image: memberData["Image"] as? String ?? "",
							joinDate: memberData["JoinDate"] as? String ?? "",
							joinStatus: memberData["JoinStatus"] as? String ?? "",
							nickName: memberData["NickName"] as? String ?? "",
                            userUID: memberData["UserUID"] as? String ?? "", 
                            simpleInfo: ""
						)
						gatheringMembers.append(member)
					}
				}

				let gathering = Gathering(gatherImage: gatherImage ?? "",
                                          gatherInfo: gatherInfo ?? "",
                                          gatherMaxMember: gatherMaxMember ?? 0,
                                          gatherName: gatherName ?? "",
                                          gatherNowMember: gatheringMembers.count,
                                          gatherQuestion: "",
                                          gatheringCreateDate: gatheringCreateDate ?? "",
                                          gatheringMaster: gatheringMaster ?? "",
                                          gatheringMembers: gatheringMembers,
                                          gatheringSports: "",
                                          gatheringSportsTeam: "", gatheringUid: gatheringUid)
				promise(.success(gathering))
			}
		}
		.eraseToAnyPublisher()
	}
}

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
// 게시판버튼 유형
enum BoardButtonType {
	case all
	case noti
	case free
}
// 가입상태
enum MembershipStatus {
	case notJoined
	case pending
	case joined
}

class GatheringDetailVM {
	@Published var gathering: Gathering?
	@Published var membershipStatus: MembershipStatus = .joined
	@Published var selectedBoardType: BoardButtonType = .all
	@Published var masterNickname: String = ""
	@Published var isMaster: Bool = false
	
	private let currentUser: LeportsUser // 현재 사용자 정보
	private let firebaseService: FirebaseServiceProtocol
	
	var cancellables = Set<AnyCancellable>()
	
	init(currentUser: LeportsUser, firebaseService: FirebaseServiceProtocol = FirebaseService()) {
		self.currentUser = currentUser
		self.firebaseService = firebaseService
	}
	
	func loadData() {
		fetchGatheringData()
	}
	
	private func fetchGatheringData() {
		firebaseService.fetchGatheringData(gatheringUid: "gathering012")
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
		isMaster = currentUser.UID == gatheringMaster
	}
	// 현재 사용자 정보
	func getCurrentUserInfo() -> LeportsUser {
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
	static let dummyUser = LeportsUser (
		UID: "user013",
		nickName: "완벽수비",
		image: "https://cdn.pixabay.com/photo/2023/08/07/19/47/water-lily-8175845_1280.jpg",
		email: "user005@example.com",
		myGathering: ["gathering012", "gathering010"],
		simpleInfo: "빠른 속도를 좋아합니다",
		userSports: "KBO",
		userSportsTeam: "두산 베어스",
		answer: "속도가 빠르기 때문입니다.",
		joinDate: "2024-01-21",
		joinStatus: "가입중"
	)
	
	struct BoardData {
		let title: String
		let createDate: String
		let boardType: BoardButtonType
	}
	
	var filteredBoardData: [BoardData] {
		switch selectedBoardType {
		case .all:
			return boardData
		case .noti, .free:
			return boardData.filter { $0.boardType == selectedBoardType }
		}
	}
	
	// 게시판 더미데이터(삭제예정)
	let boardData = [
		BoardData(title: "자유게시", createDate: "2024/09/05", boardType: .free),
		BoardData(title: "공지게시", createDate: "2024/11/05", boardType: .noti),
	]
}


extension BoardButtonType {
	var description: String {
		switch self {
		case .all:
			return "전체"
		case .noti:
			return "공지"
		case .free:
			return "자유"
		}
	}
}
