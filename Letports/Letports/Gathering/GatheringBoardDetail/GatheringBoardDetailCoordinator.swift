//
//  GatheringBoardDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit


class GatheringBoardDetailCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
	}
	
	func startWithBoardPost(boardPost: BoardPost) {
		let viewModel = GatheringBoardDetailVM(boardPost: boardPost)
		let viewController = GatheringBoardDetailVC(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
}
