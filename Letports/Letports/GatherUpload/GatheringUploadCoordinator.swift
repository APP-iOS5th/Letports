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
        let viewModel = GatheringUploadVM()
        let vc = GatheringUploadVC(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}

