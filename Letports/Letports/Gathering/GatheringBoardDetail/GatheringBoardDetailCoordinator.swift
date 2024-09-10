//
//  GatheringBoardDetailCoordinator.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation
import UIKit


class GatheringBoardDetailCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var navigationController: UINavigationController
    var viewModel: GatheringBoardDetailVM
    weak var parentCoordinator: Coordinator?
    
    init(navigationController: UINavigationController, viewModel: GatheringBoardDetailVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        self.viewModel.delegate = self
        let viewController = GatheringBoardDetailVC(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showError(message: String) {
        let alertController = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        navigationController.present(alertController, animated: true, completion: nil)
    }
}

extension GatheringBoardDetailCoordinator: GatheringBoardDetailCoordinatorDelegate {
    func boardDetailBackBtnTap() {
        navigationController.popViewController(animated: true)
        self.parentCoordinator?.childDidFinish(self)
    }
    
    func presentActionSheet(post: Post, gathering: Gathering, isWriter: Bool) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let destructiveTitle = isWriter ? "게시글 삭제" : "게시글 신고"
        let destructiveAction = UIAlertAction(title: destructiveTitle, style: .destructive) { [weak self] _ in
            
            if isWriter {
                self?.presentDeleteBoardAlert()
            } else {
                self?.viewModel.reportPost()
            }
        }
        
        let editAction = UIAlertAction(title: "게시글 수정", style: .default) { [weak self] _ in
            let gathering = gathering
            if let navigation =  self?.navigationController {
                let viewModel = BoardEditorVM(type: post.boardType, gathering: gathering, post: post)
                let coordinator = BoardEditorCoordinator(navigationController: navigation, viewModel: viewModel)
                self?.childCoordinators.append(coordinator)
                coordinator.parentCoordinator = self
                coordinator.start()
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(destructiveAction)
        if isWriter {
            alertController.addAction(editAction)
        }
        alertController.addAction(cancelAction)
        
        navigationController.present(alertController, animated: true, completion: nil)
    }
    
    func presentReportAlert() {
        let alert = UIAlertController(title: "게시글 신고", message: "해당 게시글을 신고하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "신고", style: .destructive) { _ in
            print("게시글을 신고했습니다.")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        
        self.navigationController.present(alert, animated: true, completion: nil)
    }
    
    func presentDeleteBoardAlert() {
        let alert = UIAlertController(title: "게시글 삭제", message: "해당 게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deletePost()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}
