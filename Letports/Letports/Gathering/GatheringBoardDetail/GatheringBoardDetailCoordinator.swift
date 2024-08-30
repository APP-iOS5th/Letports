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
	let allUsers: [LetportsUser]
	
	init(navigationController: UINavigationController, boardData: Post, allUsers: [LetportsUser]) {
		self.navigationController = navigationController
		self.boardData = boardData
		self.allUsers = allUsers
	}
	
	func start() {
		let viewModel = GatheringBoardDetailVM(boardPost: boardData, allUsers: allUsers)
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
