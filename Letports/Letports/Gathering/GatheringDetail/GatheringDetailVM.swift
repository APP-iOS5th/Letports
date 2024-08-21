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

struct Gathering {
	var gatherImage: String?
	var gatherName: String?
	var gatherMaxMember: Int?
	var gatherNowMember: Int?
	var gatherInfo: String?
	var gatheringCreateDate: String?
	var gatheringMaster: String?
}

// 더미 유저
struct User {
	var UID = "user005"
	var nickName = "속도광"
	var Image = "https://cdn.pixabay.com/photo/2023/08/07/19/47/water-lily-8175845_1280.jpg"
	var myGathering = ["gathering004", "gathering005"]
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
				let gatherNowMember = (data?["GatheringMembers"] as? [[String: Any]])?.count ?? 0
				let gatherInfo = data?["GatherInfo"] as? String
				let gatheringCreateDate = data?["GatheringCreateDate"] as? String
				let gatheringMaster = data?["GatheringMaster"] as? String
				
				let gathering = Gathering(
					gatherImage: gatherImage,
					gatherName: gatherName,
					gatherMaxMember: gatherMaxMember,
					gatherNowMember: gatherNowMember,
					gatherInfo: gatherInfo,
					gatheringCreateDate: gatheringCreateDate,
					gatheringMaster: gatheringMaster
				)
				
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
	@Published var isMaster: Bool = true
	@Published var membershipStatus: MembershipStatus = .joined
	@Published var selectedBoardType: BoardButtonType = .all
	
	private let firebaseService: FirebaseServiceProtocol
	var cancellables = Set<AnyCancellable>()
	
	init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
		self.firebaseService = firebaseService
		fetchGatheringData()
	}
	
	private func fetchGatheringData() {
		firebaseService.fetchGatheringData(gatheringUid: "gathering004")
			.sink(receiveCompletion: { completion in
				switch completion {
				case .finished:
					print("데이터 가져오기 완료")
				case .failure(let error):
					print("에러 발생: \(error)")
					// 에러 처리 (예: 사용자에게 알림 표시)
				}
			}, receiveValue: { [weak self] gathering in
				print("가져온 Gathering 객체:")
				print(gathering)
			})
			.store(in: &cancellables)
	}
	
	private func updateMasterStatus(gathering: Gathering) {
		// 현재 사용자가 모임장인지 확인하는 로직
		// 예: self.isMaster = (currentUserID == gathering.gatheringMaster)
	}
	
	private func updateMembershipStatus(gathering: Gathering) {
		// 현재 사용자의 모임 가입 상태를 확인하는 로직
		// 예: self.membershipStatus = ...
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
	
	
	
	// 모임 타이틀(삭제예정)
	struct GatheringHeader {
		let gatheringImage: String
		let gatheringName: String
		let gatheringMasterName: String
		let gatheringNowMember: String
		let gatheringMaxMember: String
	}
	
	// 더미데이터(삭제예정)
	let GatheringHeaders = [
		GatheringHeader(gatheringImage: "sampleImage",
						gatheringName: "수호단",
						gatheringMasterName: "매드카우",
						gatheringNowMember: "4",
						gatheringMaxMember: "10")
	]
	
	// 프로필(삭제예정)
	struct Profile {
		let userImage: String
		let userNickName: String
	}
	
	// 현재인원 더미데이터(삭제예정)
	let profiles = [
		Profile(userImage: "porfileEX2", userNickName: "수호신대장"),
	]
	
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
