//
//  GatherSettingCoordinator.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//

import UIKit

protocol GatherSettingCoordinatorDelegate: AnyObject {
    func approveJoinGathering()
    func denyJoinGathering()
    func expelGathering()
    func cancel()
}

class GatherSettingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var viewModel: GatherSettingVM
    
    init(navigationController: UINavigationController, viewModel: GatherSettingVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        let profileVC = GatherSettingVC(viewModel: viewModel)
        viewModel.delegate = self
        navigationController.pushViewController(profileVC, animated: false)
    }

}

extension GatherSettingCoordinator: GatherSettingCoordinatorDelegate {
    func cancel() {
        print("취소")
    }
    
    func approveJoinGathering() {
        print("가입승인")
    }
    
    func denyJoinGathering() {
        print("가입거절")
    }
    
    func expelGathering() {
        print("가입거절")
    }
}
