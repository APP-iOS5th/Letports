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
    let boardData: Post
    let allUsers: [LetportsUser]
    let gathering: Gathering
    var viewModel: GatheringBoardDetailVM
    
    init(navigationController: UINavigationController, viewModel: GatheringBoardDetailVM) {
        self.navigationController = navigationController
        self.boardData = viewModel.boardPost
        self.allUsers = viewModel.allUsers
        self.gathering = viewModel.gathering
        self.viewModel = viewModel
    }
    
    func start() {
        self.viewModel.delegate = self
        let viewController = GatheringBoardDetailVC(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension GatheringBoardDetailCoordinator: GatheringBoardDetailCoordinatorDelegate {
    func boardDetailBackBtnTap() {
        navigationController.popViewController(animated: true)
    }
    
    func presentActionSheet(post: Post) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "게시글 삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deletePost()
        }
        
        let editAction = UIAlertAction(title: "게시글 수정", style: .default) { [weak self] _ in
            if let gathering = self?.gathering, let navigation =  self?.navigationController {
                let viewModel = BoardEditorVM(type: post.boardType, gathering: gathering, post: post)
                let coordinator = BoardEditorCoordinator(navigationController: navigation, viewModel: viewModel)
                self?.childCoordinators.append(coordinator)
                coordinator.start()
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        alertController.addAction(cancelAction)
        
        navigationController.present(alertController, animated: true, completion: nil)
    }
}
