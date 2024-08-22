//
//  GatheringBoardDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit

class GatheringBoardDetailCoordinator: Coordinator {
	var childCoordinators: [any Coordinator] = []
	
	var navigationController: UINavigationController
	
	func start() {

	}
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
}
