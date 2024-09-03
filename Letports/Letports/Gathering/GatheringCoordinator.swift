//
//  GatheringCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

protocol GatheringCoordinatorDelegate: AnyObject {
    func presentTeamChangeController()
    func pushGatheringUploadController()
    func pushGatheringDetailController(gatheringUid: String)
}

class GatheringCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var viewModel: GatheringVM
    
    init(navigationController: UINavigationController, viewModel: GatheringVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.navigationController.isNavigationBarHidden = true
    }
    
    func start() {
        let gatheringVC = GatheringVC(viewModel: viewModel)
        viewModel.delegate = self
        gatheringVC.coordinator = self
        navigationController.setViewControllers([gatheringVC], animated: false)
    }
}

extension GatheringCoordinator: GatheringCoordinatorDelegate {
    func pushGatheringUploadController() {
        let coordinator = GatheringUploadCoordinator(navigationController: navigationController, viewModel: GatheringUploadVM())
        coordinator.start()
        childCoordinators.append(coordinator)
    }
    
    func presentTeamChangeController() {
        let coordinator = TeamSelectionCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
    }
    
    func pushGatheringDetailController(gatheringUid: String) {
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController,
                                                     currentUser: UserManager.shared.getUser(),
                                                     currentGatheringUid: gatheringUid)
        coordinator.start()
        childCoordinators.append(coordinator)
    }
}
