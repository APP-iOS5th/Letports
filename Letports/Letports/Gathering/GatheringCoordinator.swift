//
//  GatheringCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

protocol GatheringCoordinatorDelegate: AnyObject {
	func presentTeamChangeController()
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
	func presentTeamChangeController() {
		print("")
	}
	
    func pushGatheringDetailController(gatheringUid: String) {
		print("pushGathering")
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController, currentUser: GatheringDetailVM.dummyUser, currentGatheringUid: gatheringUid)
		coordinator.start()
		childCoordinators.append(coordinator)
	}
}
