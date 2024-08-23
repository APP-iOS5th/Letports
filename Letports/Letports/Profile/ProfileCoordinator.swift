import UIKit
import FirebaseAuth

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
        profileVC.coordinator = self
        navigationController.pushViewController(profileVC, animated: false)
    }

    func showEditProfile(user: LetportsUser) {
        let profileEditVM = ProfileEditVM(user: user)
        let profileEditVC = ProfileEditVC(viewModel: profileEditVM)
        navigationController.pushViewController(profileEditVC, animated: true)
    }
}
    
