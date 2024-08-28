//
//  GatheringDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit

protocol GatheringDetailCoordinatorDelegate: AnyObject {
	func pushBoardDetail(boardPost: Post, gathering: Gathering)
	func pushProfileView(member: GatheringMember)
	func presentActionSheet()
	func reportGathering()
	func presentLeaveGatheringConfirmation()
	func dismissAndUpdateUI()
	func showError(message: String)
	func gatheringDetailBackBtnTap()
	func pushGatherSettingView(gatheringUid: String)
}

class GatheringDetailCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	var viewModel: GatheringDetailVM
	
	init(navigationController: UINavigationController, currentUser: LetportsUser, currentGatheringUid: String) {
		self.navigationController = navigationController
		self.viewModel = GatheringDetailVM(currentUser: currentUser, currentGatheringUid: currentGatheringUid)
		self.viewModel.delegate = self
	}
	
	func start() {
		viewModel.delegate = self
		let vc = GatheringDetailVC(viewModel: viewModel)
		navigationController.pushViewController(vc, animated: true)
	}
}

extension GatheringDetailCoordinator: GatheringDetailCoordinatorDelegate {
	func pushGatherSettingView(gatheringUid: String) {
		let coordinator = GatherSettingCoordinator(navigationController: navigationController,
												   gatheringUid: gatheringUid)
		childCoordinators.append(coordinator)
		coordinator.start()
	}
	
	func pushBoardDetail(boardPost: Post, gathering: Gathering) {
		let coordinator = GatheringBoardDetailCoordinator(navigationController: navigationController,
														  postUID: boardPost.postUID,
														  gathering: gathering)
		childCoordinators.append(coordinator)
		coordinator.start()
	}
	
	func pushProfileView(member: GatheringMember) {
		let coordinator = UserProfileCoordinator(navigationController: navigationController, gatheringMemberUid: member.userUID)
		childCoordinators.append(coordinator)
		coordinator.start()
	}
	
	func presentActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let leaveAction = UIAlertAction(title: "모임 나가기", style: .destructive) { [weak self] _ in
			self?.presentLeaveGatheringConfirmation()
		}
		
		let reportAction = UIAlertAction(title: "신고하기", style: .default) { [weak self] _ in
			self?.reportGathering()
		}
		
		let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
		
		alertController.addAction(leaveAction)
		alertController.addAction(reportAction)
		alertController.addAction(cancelAction)
		
		navigationController.present(alertController, animated: true, completion: nil)
	}
	
	func presentLeaveGatheringConfirmation() {
		let alertController = UIAlertController(title: "모임 탈퇴",
												message: "정말로 모임을 탈퇴하시겠습니까?",
												preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
		let leaveAction = UIAlertAction(title: "나가기", style: .destructive) { [weak self] _ in
			self?.viewModel.confirmLeaveGathering()
		}
		
		alertController.addAction(cancelAction)
		alertController.addAction(leaveAction)
		
		navigationController.present(alertController, animated: true, completion: nil)
	}
	func dismissAndUpdateUI() {
		navigationController.popViewController(animated: true)
	}
	
	func showError(message: String) {
		let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
		alertController.addAction(okAction)
		navigationController.present(alertController, animated: true, completion: nil)
	}
	
	func reportGathering() {
		viewModel.reportGathering()
		// 추가적인 처리 (예: 신고 화면으로 이동 등)
	}
	
	func gatheringDetailBackBtnTap() {
		navigationController.popViewController(animated: true)
	}
	
}
