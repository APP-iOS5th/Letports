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
	// 되돌리기
	weak var parentCoordinator: TabBarCoordinator?
	
	init(navigationController: UINavigationController, currentUser: LetportsUser) {
		self.navigationController = navigationController
		self.viewModel = GatheringDetailVM(currentUser: currentUser)
		self.viewModel.coordinatorDelegate = self
	}
	
	func start() {
		viewModel.coordinatorDelegate = self
		let vc = GatheringDetailVC(viewModel: viewModel)
		navigationController.pushViewController(vc, animated: true)
	}
	
	func showBoardDetail(boardPost: Post, gathering: Gathering) {
		print("GatheringDetailCoordinator: showBoardDetail called with boardPost: \(boardPost.postUID)")
		print("GatheringDetailCoordinator: showBoardDetail called with boardPost: \(gathering)")
		let boardDetailCoordinator = GatheringBoardDetailCoordinator(navigationController: navigationController, 
																	 postUID: boardPost.postUID, 
																	 gathering: gathering)
		childCoordinators.append(boardDetailCoordinator)
		boardDetailCoordinator.start()
		print("GatheringDetailCoordinator: 새 화면으로 전환")
	}
}

