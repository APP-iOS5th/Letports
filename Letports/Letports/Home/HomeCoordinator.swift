//
//  HomeCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let homeVC = HomeVC()
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: false)
    }
}
