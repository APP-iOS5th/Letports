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
		let boardDetailCoordinator = GatheringBoardDetailCoordinator(navigationController: navigationController,
																	 postUID: boardPost.postUID,
																	 gathering: gathering)
		childCoordinators.append(boardDetailCoordinator)
		boardDetailCoordinator.start()
	}
	
	func dismissJoinView() {
		if let viewController = navigationController.viewControllers.last as? GatheringDetailVC {
			viewController.dismissJoinViewFromCoordinator()
		}
	}
	
	func presentActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let leaveAction = UIAlertAction(title: "모임 나가기", style: .destructive) { [weak self] _ in
			self?.showLeaveGatheringConfirmation()
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
	
	func showLeaveGatheringConfirmation() {
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
		// 필요한 경우 여기에 추가적인 UI 업데이트 로직을 구현하세요
	}
	
	func showError(message: String) {
		let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
		alertController.addAction(okAction)
		navigationController.present(alertController, animated: true, completion: nil)
	}
	
	
	func leaveGathering() {
		viewModel.leaveGathering()
	}
	
	func reportGathering() {
		viewModel.reportGathering()
		// 추가적인 처리 (예: 신고 화면으로 이동 등)
	}
}
