//
//  UserProfileCoordinator.swift
//  Letports
//
//  Created by mosi on 8/24/24.
//
import UIKit


class UserProfileCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let userProfileVM = UserProfileVM()
        let userProfileVC = UserProfileVC(viewModel: userProfileVM)
        navigationController.pushViewController(userProfileVC, animated: false)
    }
}


