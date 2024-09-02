//
//  GatheringVM.swift
//  Letports
//
//  Created by 홍준범 on 8/23/24.
//

import Foundation
import Combine
import FirebaseFirestore

enum GatheringCellType {
    case recommendGatheringHeader
    case recommendGatherings
    case gatheringListHeader
    case gatheringLists
}

class GatheringVM {
    @Published var recommendGatherings: [Gathering] = []
    @Published var gatheringLists: [Gathering] = []
    @Published var masterUsers: [String: LetportsUser] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore()

    weak var delegate: GatheringCoordinatorDelegate?
    
    func presentTeamChangeController() {
        
    }
    
    func pushGatheringDetailController(gatheringUid: String) {
        self.delegate?.pushGatheringDetailController(gatheringUid: gatheringUid)
    }
    
    func pushGatheringUploadController() {
        self.delegate?.pushGatheringUploadController()
    }
    
    
    private var cellType: [GatheringCellType] {
        var cellTypes: [GatheringCellType] = []
        cellTypes.append(.recommendGatheringHeader)
        for _ in recommendGatherings {
            cellTypes.append(.recommendGatherings)
        }
        cellTypes.append(.gatheringListHeader)
        for _ in gatheringLists {
            cellTypes.append(.gatheringLists)
        }
        return cellTypes
    }
    
    func getCellTypes() -> [GatheringCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    init() {
        UserManager.shared.getTeam { result in
            switch result {
            case .success(let team):
                self.loadGatherings(forTeam: team.teamUID)
            case .failure(let error):
                print("getTeam Error \(error)")
            }
        }
    }
    
    //Gathering 정보 가져오기
    func loadGatherings(forTeam teamName: String) {
        db.collection("Gatherings")
            .whereField("GatheringSportsTeam", isEqualTo: teamName)
            .getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error fetching gatherings: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                // Gathering 객체로 변환하여 recommendGatherings 및 gatheringLists에 저장
                let gatherings = documents.compactMap { document in
                    try? document.data(as: Gathering.self)
                }
                
                // Gathering 객체를 생성일자(gatheringCreateDate) 기준으로 정렬
                let sortedGatherings = gatherings.sorted { gathering1, gathering2 in
                    return gathering1.gatheringCreateDate.dateValue() < gathering2.gatheringCreateDate.dateValue()
                }
                
                // 정렬된 리스트 중에서 상위 2개를 추천 목록으로 저장
                self?.recommendGatherings = Array(sortedGatherings.prefix(2))
                
                // 전체 리스트를 gatheringLists에 저장
                self?.gatheringLists = sortedGatherings
            }
    }
    
    func getRecommendGatheringCount() -> Int {
        return self.recommendGatherings.count
    }
    
    func fetchMasterUser(masterId: String) {
        guard masterUsers[masterId] == nil else { return }
        let collectionPath: [FirestorePathComponent] = [
            .collection(.user),
            .document(masterId),
        ]
        FM.getData(pathComponents: collectionPath, type: LetportsUser.self)
            .compactMap { $0.first }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] masterUser in
                self?.masterUsers[masterId] = masterUser
            }
            .store(in: &cancellables)
    }
}


