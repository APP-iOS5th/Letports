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
	let gathering: Gathering
	
	init(navigationController: UINavigationController, postUID: String, gathering: Gathering) {
		self.navigationController = navigationController
		self.postUID = postUID
		self.gathering = gathering
	}
	
	func start() {
		let viewModel = GatheringBoardDetailVM(postUID: postUID, gathering: gathering)
		let viewController = GatheringBoardDetailVC(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
}
