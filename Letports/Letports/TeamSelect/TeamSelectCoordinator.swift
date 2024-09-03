//
//  SelectTeamCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/30/24.
//

import UIKit

class TeamSelectCoordinator: Coordinator {
    weak var parentCoordinator: AppCoordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = TeamSelectVM()
        let teamSelectVC = TeamSelectVC(viewModel: viewModel)
        teamSelectVC.coordinator = self
        navigationController.setViewControllers([teamSelectVC], animated: true)
    }
    
    func didFinishTeamSelect() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.parentCoordinator?.showMainView()
        }
    }
}
