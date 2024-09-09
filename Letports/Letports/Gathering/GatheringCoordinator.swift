//
//  GatheringCoordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

protocol GatheringCoordinatorDelegate: AnyObject {
    func presentTeamChangeController()
    func pushGatheringUploadController()
    func pushGatheringDetailController(gatheringUid: String, teamColor: String)
    func endUploadGathering()
}

class GatheringCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var navigationController: UINavigationController
    var viewModel: GatheringVM
    
    init(navigationController: UINavigationController, viewModel: GatheringVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.navigationController.isNavigationBarHidden = true
    }
    
    func start() {
        let gatheringVC = GatheringVC(viewModel: viewModel)
        viewModel.delegate = self
        gatheringVC.coordinator = self
        navigationController.setViewControllers([gatheringVC], animated: false)
    }
}

extension GatheringCoordinator: GatheringCoordinatorDelegate {
    func pushGatheringUploadController() {
        let coordinator = GatheringUploadCoordinator(navigationController: navigationController, 
                                                     viewModel: GatheringUploadVM())
        coordinator.start()
        coordinator.delegate = self
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }
    
    func presentTeamChangeController() {
        let coordinator = TeamSelectCoordinator(navigationController: navigationController)
        coordinator.presentStart()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }
    
    func pushGatheringDetailController(gatheringUid: String, teamColor: String) {
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController,
                                                     currentUser: UserManager.shared.getUser(),
                                                     currentGatheringUid: gatheringUid, teamColor: teamColor)
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }
    
    func endUploadGathering() {
        if let gatheringVC = navigationController.viewControllers.first(where: { $0 is GatheringVC }) as? GatheringVC {
            gatheringVC.loadGathering()
        }
    }
}
