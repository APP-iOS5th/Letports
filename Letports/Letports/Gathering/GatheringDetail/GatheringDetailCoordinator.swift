//
//  GatheringDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit

protocol GatheringDetailCoordinatorDelegate: AnyObject {
	func didSettingBtnTap()
	func didJoinBtnTap()
	func didEditBtnTap()
	func didNotiRegiBtnTap()
	func didBoardRegiBtnTap()
	func didBackBtnTap()
	func didCellTap(boardPost: BoardPost)
}

class GatheringDetailCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
		let viewModel = GatheringDetailVM(currentUser: GatheringDetailVM.dummyUser)
		let viewController = GatheringDetailVC(viewModel: viewModel)
		viewController.delegate = self
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func didSettingBtnTap() {
		
	}
	
	func didJoinBtnTap() {
		
	}
	
	func didEditBtnTap() {
		
	}
	
	func didBackBtnTap() {
		
	}
}

extension GatheringDetailCoordinator: GatheringDetailCoordinatorDelegate {
	func didCellTap(boardPost: BoardPost) {
			let boardDetailCoordinator = GatheringBoardDetailCoordinator(navigationController: navigationController)
			childCoordinators.append(boardDetailCoordinator)
		boardDetailCoordinator.startWithBoardPost(boardPost: boardPost)
		}
	
	func didNotiRegiBtnTap() {
		
	}
	
	func didBoardRegiBtnTap() {
		
	}
}


