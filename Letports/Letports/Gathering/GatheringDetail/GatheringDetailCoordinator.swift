//
//  GatheringDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit

protocol GatheringDetailCoordinatorDelegate: AnyObject {
    func pushBoardDetail(gathering: Gathering, boardPost: Post, allUsers: [LetportsUser])
	func pushProfileView(member: LetportsUser)
	func presentActionSheet()
	func reportGathering()
	func presentLeaveGatheringConfirmation()
	func dismissAndUpdateUI()
	func showError(message: String)
	func gatheringDetailBackBtnTap()
    func pushGatherSettingView(gathering: Gathering)
	func pushPostUploadViewController(type: PostType, gathering: Gathering)
    func pushGatheringEditView(gathering: Gathering)
}

class GatheringDetailCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	var viewModel: GatheringDetailVM
    weak var delegate: ProfileCoordinatorDelegate?
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
	func pushPostUploadViewController(type: PostType, gathering: Gathering) {
        let viewModel = BoardEditorVM(type: type, gathering: gathering)
		let coordinaotr = BoardEditorCoordinator(navigationController: navigationController, viewModel: viewModel)
        childCoordinators.append(coordinaotr)
        coordinaotr.start()
	}
	
    func pushGatherSettingView(gathering: Gathering) {
		let coordinator = GatherSettingCoordinator(navigationController: navigationController,
                                                   gathering: gathering)
		childCoordinators.append(coordinator)
		coordinator.start()
	}
	
    func pushBoardDetail(gathering: Gathering, boardPost: Post, allUsers: [LetportsUser]) {
        let viewModel = GatheringBoardDetailVM(boardPost: boardPost, allUsers: allUsers, gathering: gathering)
        
		let coordinator = GatheringBoardDetailCoordinator(navigationController: navigationController,
                                                          viewModel: viewModel)
		childCoordinators.append(coordinator)
		coordinator.start()
	}
	
	func pushProfileView(member: LetportsUser) {
		let coordinator = UserProfileCoordinator(navigationController: navigationController, gatheringMemberUid: member.uid)
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
	
//	func presentCancelWaiting() {
//		let alertController = UIAlertController(title: "가입 대기 취소",
//												message: "정말로 가입대기를 취소하시겠습니까?",
//												preferredStyle: .alert)
//		
//		let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
//		let leaveAction = UIAlertAction(title: "신청취소", style: .destructive) { [weak self] _ in
//			self?.viewModel.confirmCancelWaiting()
//		}
//		
//		alertController.addAction(cancelAction)
//		alertController.addAction(leaveAction)
//		
//		navigationController.present(alertController, animated: true, completion: nil)
//	}
    
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
        delegate?.didFinishEditingOrDetail()
	}
    
    func pushGatheringEditView(gathering: Gathering) {
        let viewModel = GatheringUploadVM(gathering: gathering)
        let coordinator = GatheringUploadCoordinator(navigationController: navigationController, viewModel: viewModel)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
	
}

