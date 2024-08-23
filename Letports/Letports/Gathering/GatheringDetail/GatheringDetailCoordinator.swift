//
//  GatheringDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit

class GatheringDetailCoordinator: Coordinator, GatheringDetailCoordinatorDelegate {
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	var viewModel: GatheringDetailVM
	
	init(navigationController: UINavigationController, currentUser: User) {
		self.navigationController = navigationController
		self.viewModel = GatheringDetailVM(currentUser: currentUser)
	}
	
	func start() {
		let vc = GatheringDetailVC(viewModel: viewModel)
		navigationController.pushViewController(vc, animated: true)
	}
	
	func showBoardDetail(for boardPost: BoardPost) {
		let boardDetailCoordinator = GatheringBoardDetailCoordinator(navigationController: navigationController, 
																	 boardPost: boardPost)
		childCoordinators.append(boardDetailCoordinator)
		boardDetailCoordinator.start()
	}
}
