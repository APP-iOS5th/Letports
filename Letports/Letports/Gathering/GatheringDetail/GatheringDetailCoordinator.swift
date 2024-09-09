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
    func presentReportConfirmView()
}

class GatheringDetailCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
	var navigationController: UINavigationController
	var viewModel: GatheringDetailVM
    weak var parentCoordinator: Coordinator?
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
        coordinaotr.parentCoordinator = self
        coordinaotr.start()
	}
	
    func pushGatherSettingView(gathering: Gathering) {
		let coordinator = GatherSettingCoordinator(navigationController: navigationController,
                                                   gathering: gathering)
		childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
		coordinator.start()
	}
	
    func pushBoardDetail(gathering: Gathering, boardPost: Post, allUsers: [LetportsUser]) {
        let viewModel = GatheringBoardDetailVM(boardPost: boardPost, allUsers: allUsers, gathering: gathering)
        
		let coordinator = GatheringBoardDetailCoordinator(navigationController: navigationController,
                                                          viewModel: viewModel)
		childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
		coordinator.start()
	}
	
    func pushProfileView(member: LetportsUser) {
        let viewModel = ProfileVM(profileType: .userProfile, userUID: member.uid)
        let coordinator = ProfileCoordinator(navigationController: navigationController, viewModel: viewModel)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        let profileVC = ProfileVC(viewModel: viewModel)
        profileVC.hidesBottomBarWhenPushed = true
        
        viewModel.delegate = coordinator
        navigationController.pushViewController(profileVC, animated: true)
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
												message: "정말로 모임을 탈퇴하시겠습니까?\n작성한 게시글도 삭제됩니다",
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
        self.parentCoordinator?.childDidFinish(self)
	}
    
    func pushGatheringEditView(gathering: Gathering) {
        let viewModel = GatheringUploadVM(gathering: gathering)
        let coordinator = GatheringUploadCoordinator(navigationController: navigationController, viewModel: viewModel)
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    func presentReportConfirmView() {
        let alert = UIAlertController(title: "모임 신고", message: "해당 모임을 신고하시겠습니까?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "신고", style: .destructive) { _ in
            print("모임을 신고했습니다.")
        }

        alert.addAction(cancelAction)
        alert.addAction(reportAction)

        self.navigationController.present(alert, animated: true, completion: nil)
    }
	
}

