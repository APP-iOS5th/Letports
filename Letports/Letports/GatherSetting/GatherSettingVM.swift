import UIKit
import Combine
import FirebaseFirestore

enum GatheringSettingCellType {
	case pendingGatheringUserTtitle
	case pendingGatheringUser
	case joiningGatheringUserTitle
	case joiningGatheringUser
	case settingTitle
	case deleteGathering
}

class GatherSettingVM {
	@Published var gathering: SampleGathering1?
	@Published var pendingGatheringMembers: [SampleMember] = []
	@Published var joiningGatheringMembers: [SampleMember] = []
	
	private var cancellables = Set<AnyCancellable>()
	weak var delegate: GatherSettingCoordinatorDelegate?
	
	private var cellType: [GatheringSettingCellType] {
		var cellTypes: [GatheringSettingCellType] = []
		cellTypes.append(.pendingGatheringUserTtitle)
		for _ in pendingGatheringMembers {
			cellTypes.append(.pendingGatheringUser)
		}
		cellTypes.append(.joiningGatheringUserTitle)
		for _ in joiningGatheringMembers {
			cellTypes.append(.joiningGatheringUser)
		}
		cellTypes.append(.settingTitle)
		cellTypes.append(.deleteGathering)
		return cellTypes
	}
	
	init(gatheringUid: String) {
		loadGathering(with: gatheringUid)
	}
	
	func denyUser() {
		delegate?.denyJoinGathering()
	}
	
	func approveUser() {
		delegate?.approveJoinGathering()
	}
	
	func expelUser() {
		delegate?.expelGathering()
	}
	
	func cancel() {
		delegate?.cancel()
	}
	
	func gatherSettingBackBtnTap() {
		delegate?.gatherSettingBackBtnTap()
	}
	
	func getCellTypes() -> [GatheringSettingCellType] {
		return self.cellType
	}
	
	func getCellCount() -> Int {
		return self.cellType.count
	}
	
	func loadGathering(with GatheringUid: String) {
		FM.getData(collection: "Gatherings", document: GatheringUid, type: SampleGathering1.self)
			.sink { completion in
				switch completion {
				case .finished:
					print("loadGathering->finished")
					break
				case .failure(let error):
					print("loadGatherings->",error.localizedDescription)
				}
			} receiveValue: { [weak self] fetchedGathering in
				print("loadGathering->finished")
				self?.gathering = fetchedGathering
				self?.fetchGatheringMembers(for: fetchedGathering)
			}
			.store(in: &cancellables)
	}
	
	func fetchGatheringMembers(for gathering: SampleGathering1) {
		guard !gathering.gatheringMembers.isEmpty else {
			self.pendingGatheringMembers = []
			self.joiningGatheringMembers = []
			return
		}
		FM.getData(collection: "Gatherings", document: gathering.gatheringUid, type: SampleGathering1.self)
			.map { gathering in
				let joining = gathering.gatheringMembers.filter { $0.joinStatus == "가입중" }
				let pending = gathering.gatheringMembers.filter { $0.joinStatus == "가입대기중" }
				return (joining, pending)
			}
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: {  completion in
				switch completion {
				case .finished:
					break
				case .failure(let error):
					print("loadGatheringUser->",error.localizedDescription)
				}
			}, receiveValue: { [weak self] (joining, pending) in
				self?.joiningGatheringMembers = joining
				self?.pendingGatheringMembers = pending
			})
			.store(in: &cancellables)
	}
}
