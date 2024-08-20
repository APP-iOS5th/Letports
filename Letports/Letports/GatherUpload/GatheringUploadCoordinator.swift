//
//  GatheringBoardUploadCoordinaotr.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import Foundation
import UIKit

class GatheringUploadCoordinator: Coordinator {
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init() {
        self.navigationController = .init()
    }
    
    func start() {
                let gather = SampleGathering(gatheringSports: "KBO", gatheringTeam: "두산 베어스",
                                             gatheringUID: "gathering001", gatheringMaster: "user001",
                                             gatheringName: "두산 베어스 팬클럽", gatheringImage: "https://cdn.pixabay.com/photo/2021/11/23/09/12/mountains-6818253_1280.jpg",
                                             gatherMaxMember: 22, gatherNowMember: 3,
                                             gatherInfo: "두산 베어스를 사랑하는 팬들의 모임입니다.", gatherQuestion: "두산 베어스를 좋아하는 이유는?",
                                             gatheringMembers: [], gatheringCreateDate: Date())
        let viewModel = GatheringUploadVM()
        let vc = GatheringUploadVC(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}

