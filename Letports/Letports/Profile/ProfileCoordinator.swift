//
//  ProfileCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let profileVC = ProfileVC()
        profileVC.coordinator = self
        navigationController.setViewControllers([profileVC], animated: false)
    }
}
