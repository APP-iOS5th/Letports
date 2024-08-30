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
	let boardData: Post
	let gathering: Gathering
	
	init(navigationController: UINavigationController, boardData: Post, gathering: Gathering) {
		self.navigationController = navigationController
		self.boardData = boardData
		self.gathering = gathering
	}
	
	func start() {
		let viewModel = GatheringBoardDetailVM(boardPost: boardData, gathering: gathering)
		viewModel.delegate = self
		let viewController = GatheringBoardDetailVC(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
}

extension GatheringBoardDetailCoordinator: GatheringBoardDetailCoordinatorDelegate {
	func boardDetailBackBtnTap() {
		navigationController.popViewController(animated: true)
	}
}
