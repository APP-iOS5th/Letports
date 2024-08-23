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
    case GatheringListHeader
    case GatheringLists
}

class GatheringVM {
    @Published var recommendGatherings: [Gathering] = []
    @Published var gatheringLists: [Gathering] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private var cellType: [GatheringCellType] {
        var cellTypes: [GatheringCellType] = []
        cellTypes.append(.recommendGatheringHeader)
        for _ in recommendGatherings {
            cellTypes.append(.recommendGatherings)
        }
        cellTypes.append(.GatheringListHeader)
        for _ in gatheringLists {
            cellTypes.append(.GatheringLists)
        }
        return cellTypes
    }
    
    func getCellTypes() -> [GatheringCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
//    init() {
//        loadGathering(with GatheringUID: String)
//    }
    
    //Gathering 정보 가져오기 <도움 요청>
//    FM.getDocuments(collection: "Gatherings", documentIds: <#T##[String]#>, type: <#T##T#>)
//        .sink(re)
    
    
    
    
}
