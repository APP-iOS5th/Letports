import UIKit
import FirebaseAuth


protocol ProfileCoordinatorDelegate: AnyObject {
    func presentEditProfileController(user: LetportsUser)
    func presentSettingViewController()
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String)
    func didUpdateProfile()
    func backToGatheringDetail()
}

class ProfileCoordinator: Coordinator {
    weak var parentCoordinator: TabBarCoordinator?
    var childCoordinators: [Coordinator] = []
    var viewModel : ProfileVM
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController, viewModel: ProfileVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        let profileVC = ProfileVC(viewModel: viewModel)
        viewModel.delegate = self
        navigationController.pushViewController(profileVC, animated: false)
    }
}

extension ProfileCoordinator: ProfileCoordinatorDelegate {
    func backToGatheringDetail() {
        navigationController.popViewController(animated: true)
    }
    
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String) {
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController, currentUser: currentUser, currentGatheringUid: gatheringUid)
        childCoordinators.append(coordinator)
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
    
    func didUpdateProfile() {
        if let profileVC = navigationController.viewControllers.first(where: { $0 is ProfileVC }) as? ProfileVC {
            profileVC.reloadProfileData()
        }
    }
}
