import UIKit
import FirebaseAuth


protocol ProfileCoordinatorDelegate: AnyObject {
    func dismissViewController()
    func presentEditProfileController(user: LetportsUser)
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
    
    func presentEditProfileController(user: LetportsUser) {
        let coordinator = ProfileEditCoordinator(navigationController: navigationController, viewModel: ProfileEditVM(user: user))
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func dismissViewController() {
        self.navigationController.dismiss(animated: true)
    }
    
}
