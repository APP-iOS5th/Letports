//
//  HomeCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
	func presentURLController(with url: URL)
	func presentTeamChangeController()
    func pushGatheringDetailController(gatheringUID: String)
}

class HomeCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
	var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
	var navigationController: UINavigationController
	var viewModel: HomeViewModel
	
	init(navigationController: UINavigationController, viewModel: HomeViewModel) {
		self.navigationController = navigationController
		self.viewModel = viewModel
        self.navigationController.isNavigationBarHidden = true
	}
	
	func start() {
		let homeVC = HomeVC(viewModel: viewModel)
		viewModel.delegate = self
		homeVC.coordinator = self
		navigationController.setViewControllers([homeVC], animated: false)
	}
}

extension HomeCoordinator: HomeCoordinatorDelegate {

	func presentTeamChangeController() {
		let coordinator = TeamSelectionCoordinator(navigationController: navigationController)
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
	}
	
    func pushGatheringDetailController(gatheringUID: String) {
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController, currentUser: UserManager.shared.getUser(), currentGatheringUid: gatheringUID)
		coordinator.start()
        coordinator.parentCoordinator = self
		childCoordinators.append(coordinator)
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
