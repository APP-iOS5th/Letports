//
//  ProfileEditCoordinator.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//
import UIKit

class ProfileEditCoordinator {
  
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(with user: LetportsUser) {
        // ProfileEditVM을 생성하고 ProfileEditVC에 전달
        let profileEditVM = ProfileEditVM(user: user)
        let profileEditVC = ProfileEditVC(viewModel: profileEditVM)
        navigationController.pushViewController(profileEditVC, animated: true)
    }
}


