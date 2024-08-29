//
//  GatherSettingCoordinator.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//

import UIKit

protocol GatherSettingCoordinatorDelegate: AnyObject {
	func approveJoinGathering()
	func denyJoinGathering()
	func expelGathering()
	func cancel()
	func gatherSettingBackBtnTap()
}

class GatherSettingCoordinator: Coordinator {
	var childCoordinators = [Coordinator]()
	var navigationController: UINavigationController
	var viewModel: GatherSettingVM
	
	init(navigationController: UINavigationController, gatheringUid: String) {
		self.navigationController = navigationController
		self.viewModel = GatherSettingVM(gatheringUid: gatheringUid)
	}
	
	func start() {
		let profileVC = GatherSettingVC(viewModel: viewModel)
		viewModel.delegate = self
		navigationController.pushViewController(profileVC, animated: true)
	}
	
}

extension GatherSettingCoordinator: GatherSettingCoordinatorDelegate {
	func cancel() {
		print("취소")
	}
	
	func approveJoinGathering() {
		print("가입승인")
	}
	
	func denyJoinGathering() {
		print("가입거절")
	}
	
	func expelGathering() {
		print("가입거절")
	}
	
	func gatherSettingBackBtnTap() {
		navigationController.popViewController(animated: true)
	}
}
