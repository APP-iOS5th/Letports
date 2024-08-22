//
//  GatheringDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit

protocol GatheringDetailCoordinatorDelegate: AnyObject {
	func didSettingBtnTap()
	func didJoinBtnTap()
	func didEditBtnTap()
	func didRequestReportGathering()
	func didDeleteidBtnTap()
	func didNotiRegiBtnTap()
	func didBoardRegiBtnTap()
	func didBackBtnTap()
}

class GatheringDetailCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
		let viewModel = GatheringDetailVM(currentUser: GatheringDetailVM.dummyUser)
		let viewController = GatheringDetailVC(viewModel: viewModel)
		viewController.delegate = self
		navigationController.pushViewController(viewController, animated: true)
	}
}

extension GatheringDetailCoordinator: GatheringDetailCoordinatorDelegate {
	func didSettingBtnTap() {
		<#code#>
	}
	
	func didJoinBtnTap() {
		<#code#>
	}
	
	func didEditBtnTap() {
		<#code#>
	}
	
	func didRequestReportGathering() {
		<#code#>
	}
	
	func didDeleteidBtnTap() {
		<#code#>
	}
	
	func didNotiRegiBtnTap() {
		<#code#>
	}
	
	func didBoardRegiBtnTap() {
		<#code#>
	}
	
	func didBackBtnTap() {
		<#code#>
	}
}


