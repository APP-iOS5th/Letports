//
//  GatheringCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class GatheringCoordinator: Coordinator {
	weak var parentCoordinator: TabBarCoordinator?
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
		let gatheringVC = GatheringVC()
		gatheringVC.coordinator = self
		navigationController.setViewControllers([gatheringVC], animated: false)
	}
}
