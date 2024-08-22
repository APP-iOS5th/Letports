//
//  GatheringDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit

protocol GatheringDetailCoordinatorDelegate: AnyObject {
	func didRequestShowActionSheet()
	func didRequestJoinGathering()
	func didRequestLeaveGathering()
	func didRequestReportGathering()
}

protocol GatheringDetailVCDelegate: AnyObject {
	func didTapJoinBtn()
	func didTapSettingsBtn()
}

class GatheringDetailCoordinator: Coordinator, GatheringDetailVCDelegate {
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
	
	private func showActionSheet() {
		let actionSheet = ActionSheetVC()
		actionSheet.delegate = self
		actionSheet.modalPresentationStyle = .overFullScreen
		actionSheet.modalTransitionStyle = .crossDissolve
		navigationController.present(actionSheet, animated: true)
	}
	
	private func showJoinQuestionView() {
		let signupVC = SignupVC()
		signupVC.delegate = self
		signupVC.modalPresentationStyle = .overFullScreen
		navigationController.present(signupVC, animated: true)
	}
	
	func didTapJoinBtn() {
		showJoinQuestionView()
		print("가입하기")
	}
	
	func didTapSettingsBtn() {
		showActionSheet()
	}
}

// 신고하기 탈퇴하기버튼
extension GatheringDetailCoordinator: ActionSheetViewDelegate {
	func didTapLeaveGathering() {
		// 모임 나가기 로직
		navigationController.dismiss(animated: true)
	}
	
	func didTapReportGathering() {
		// 모임 신고하기 로직
		navigationController.dismiss(animated: true)
	}
	
	func didTapCancel() {
		navigationController.dismiss(animated: true)
	}
}

// signView에서 가입신청, 취소버튼을 누르면
extension GatheringDetailCoordinator: SignupVCDelegate {
	func signupVCDidTapApplyBtn(_ viewController: SignupVC) {
		// 가입 신청 로직 구현
		print("가입 신청")
		navigationController.dismiss(animated: true)
	}
	
	func signupVCDidTapCancelBtn(_ viewController: SignupVC) {
		navigationController.dismiss(animated: true)
	}
}
