//
//  UserProfileCoordinator.swift
//  Letports
//
//  Created by mosi on 8/24/24.
//
import UIKit


class UserProfileCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    
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
	func userProfileBackBtnDidTap() {
		navigationController.popViewController(animated: true)
        self.parentCoordinator?.childDidFinish(self)
	}
}


