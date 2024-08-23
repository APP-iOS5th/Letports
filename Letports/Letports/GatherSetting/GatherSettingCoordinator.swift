//
//  GatherSettingCoordinator.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//

import UIKit

class GatherSettingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var gatherSettingVC: GatherSettingVC?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let gatherSettingVM = GatherSettingVM()
        let gatherSettingVC = GatherSettingVC(viewModel: gatherSettingVM)
        gatherSettingVC.coordinator = self
        navigationController.pushViewController(gatherSettingVC, animated: false)
    }
}
