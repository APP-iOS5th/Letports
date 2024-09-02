import UIKit
import FirebaseAuth


protocol ProfileCoordinatorDelegate: AnyObject {
    func presentEditProfileController(user: LetportsUser)
    func presentSettingViewController()
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String)
    func didFinishEditingOrDetail()
}

class ProfileCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let profileVM = ProfileVM()
        let profileVC = ProfileVC(viewModel: profileVM)
        profileVM.delegate = self
        navigationController.pushViewController(profileVC, animated: false)
    }
}

extension ProfileCoordinator: ProfileCoordinatorDelegate {
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String) {
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController, currentUser: currentUser, currentGatheringUid: gatheringUid)
        childCoordinators.append(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func presentSettingViewController() {
        navigationController.pushViewController(SettingVC(), animated: false)
    }
    
    func presentEditProfileController(user: LetportsUser) {
        let coordinator = ProfileEditCoordinator(navigationController: navigationController, viewModel: ProfileEditVM(user: user))
        childCoordinators.append(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func reloadProfileData() {
        if let profileVC = navigationController.viewControllers.first(where: { $0 is ProfileVC }) as? ProfileVC {
            profileVC.reloadProfileData()
        }
    }
    
    func didFinishEditingOrDetail() {
        reloadProfileData()
    }
}
