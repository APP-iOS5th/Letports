//
//  GatherSettingCoordinator.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//

import UIKit
import Combine

protocol GatherSettingCoordinatorDelegate: AnyObject {
    func gatherSettingBackBtnTap()
    func gatherDeleteFinish()
}

class GatherSettingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]() {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var navigationController: UINavigationController
    var viewModel: GatherSettingVM
    weak var parentCoordinator: Coordinator?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController, gatheringUid: String) {
        self.navigationController = navigationController
        self.viewModel = GatherSettingVM(gatheringUid: gatheringUid)
    }
    
    func start() {
        let vc = GatherSettingVC(viewModel: viewModel)
        viewModel.delegate = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
}

extension GatherSettingCoordinator: GatherSettingCoordinatorDelegate {
    func gatherDeleteFinish() {
        DispatchQueue.main.async {
            self.navigationController.popToRootViewController(animated: true)
            self.parentCoordinator?.childDidFinish(self)
            self.reloadParentView()
        }
    }
    
    func gatherSettingBackBtnTap() {
        navigationController.popViewController(animated: true)
        self.parentCoordinator?.childDidFinish(self)
    }
    
    private func reloadParentView() {
        for viewController in navigationController.viewControllers {
            if let homeVC = viewController as? HomeVC {
                homeVC.reloadTeamData()
            } else if let gatheringVC = viewController as? GatheringVC {
                gatheringVC.loadGathering()
            } else if let profileVC = viewController as? ProfileVC {
                profileVC.reloadProfileData()
            }
        }
    }
}
