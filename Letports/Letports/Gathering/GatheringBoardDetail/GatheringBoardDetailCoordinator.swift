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
	let postUID: String
	let gathering: SampleGathering2
	
	init(navigationController: UINavigationController, postUID: String, gathering: SampleGathering2) {
		self.navigationController = navigationController
		self.postUID = postUID
		self.gathering = gathering
	}
	
	func start() {
		let viewModel = GatheringBoardDetailVM(postUID: postUID, gathering: gathering)
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
