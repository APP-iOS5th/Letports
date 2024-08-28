import UIKit
import FirebaseAuth


protocol ProfileCoordinatorDelegate: AnyObject {
    func dismissViewController()
    func presentEditProfileController(user: LetportsUser)
    func presentSettingViewController()
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String)
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
    func presentSettingViewController() {
        print("셋팅뷰 출력")
        navigationController.pushViewController(SettingVC(), animated: false)
    }
    
    func presentEditProfileController(user: LetportsUser) {
        let coordinator = ProfileEditCoordinator(navigationController: navigationController, viewModel: ProfileEditVM(user: user))
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String) {
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController, currentUser: currentUser, currentGatheringID: gatheringUid)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func dismissViewController() {
        self.navigationController.dismiss(animated: true)
    }
}
