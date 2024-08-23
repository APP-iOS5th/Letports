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
	var viewModel: GatheringBoardDetailVM

	init(navigationController: UINavigationController, boardPost: BoardPost) {
		self.navigationController = navigationController
		self.viewModel = GatheringBoardDetailVM(boardPost: boardPost)
	}
	
	func start() {
		let vc = GatheringBoardDetailVC(viewModel: viewModel)
		navigationController.pushViewController(vc, animated: true)
	}
}
