//
//  SelectTeamCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/30/24.
//

import UIKit

class TeamSelectCoordinator: Coordinator {
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
    
    func presentStart() {
        let viewModel = TeamSelectVM()
        let teamSelectVC = TeamSelectVC(viewModel: viewModel)
        teamSelectVC.coordinator = self
        navigationController.present(teamSelectVC, animated: true)
    }
    
    
    func didFinishTeamSelect(_ team: SportsTeam? = nil) {
        navigationController.dismiss(animated: true) { [weak self] in
            if (self?.parentCoordinator) is AppCoordinator  {
                (self?.parentCoordinator as? AppCoordinator)?.showMainView()
            } else {
                if let team = team {
                    UserManager.shared.setTeam(selectTeam: team)
                }
            }
            self?.parentCoordinator?.childDidFinish(self)
        }
    }
}
