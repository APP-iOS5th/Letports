//
//  SelectTeamCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/30/24.
//

import UIKit

class TeamSelectionCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
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
        (parentCoordinator as? AppCoordinator)?.showMainView()
    }
}
