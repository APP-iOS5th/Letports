//
//  HomeCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
	func presentURLController(with url: URL)
	func teamChangeController()
	func pushGatheringDetailController()
}

class HomeCoordinator: Coordinator {
	weak var parentCoordinator: TabBarCoordinator?
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	var viewModel: HomeViewModel
	
	init(navigationController: UINavigationController, viewModel: HomeViewModel) {
		self.navigationController = navigationController
		self.viewModel = viewModel
	}
	
	func start() {
		let homeVC = HomeVC(viewModel: viewModel)
		viewModel.delegate = self
		homeVC.coordinator = self
		navigationController.setViewControllers([homeVC], animated: false)
	}
}

extension HomeCoordinator: HomeCoordinatorDelegate {
	func teamChangeController() {
		print("teamChangeButton")
	}
	
	func pushGatheringDetailController() {
//        let coordinator = GatheringDetailCoordinator(navigationController: navigationController, currentUser: GatheringDetailVM.dummyUser, currentGatheringID: <#String#>)
//		coordinator.start()
//		childCoordinators.append(coordinator)
	}
	
	func presentURLController(with url: URL) {
		presentBottomSheet(with: url)
	}
	
	func presentBottomSheet(with url: URL) {
		let bottomSheetVC = URLVC(url: url)
		bottomSheetVC.modalPresentationStyle = .pageSheet
		
		let detentIdentifier = UISheetPresentationController.Detent.Identifier("customDetent")
		let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
			let screenHeight = UIScreen.main.bounds.height
			return screenHeight * 0.878912
		}
		
		if let sheet = bottomSheetVC.sheetPresentationController {
			sheet.detents = [customDetent]
			sheet.preferredCornerRadius = 30
			sheet.prefersGrabberVisible = true
		}
		
		self.navigationController.present(bottomSheetVC, animated: true, completion: nil)
	}
}
