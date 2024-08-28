//
//  UserProfileCoordinator.swift
//  Letports
//
//  Created by mosi on 8/24/24.
//
import UIKit


class UserProfileCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
	let gatheringMemberUid: String
    
    init(navigationController: UINavigationController, gatheringMemberUid: String) {
        self.navigationController = navigationController
		self.gatheringMemberUid = gatheringMemberUid
    }
    
    func start() {
        let userProfileVM = UserProfileVM(userUID: gatheringMemberUid)
        let userProfileVC = UserProfileVC(viewModel: userProfileVM)
		userProfileVM.delegate = self
        navigationController.pushViewController(userProfileVC, animated: false)
    }
}

extension UserProfileCoordinator: UserProfileCoordinatorDelegate {
	func userProfileBackBtn() {
		navigationController.popViewController(animated: true)
	}
}


