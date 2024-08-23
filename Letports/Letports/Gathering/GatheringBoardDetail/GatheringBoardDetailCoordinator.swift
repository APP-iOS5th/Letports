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
	
	init(navigationController: UINavigationController, postUID: String) {
		self.navigationController = navigationController
		self.postUID = postUID
	}
	
	func start() {
		let viewModel = GatheringBoardDetailVM(postUID: postUID)
		let viewController = GatheringBoardDetailVC(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
}
