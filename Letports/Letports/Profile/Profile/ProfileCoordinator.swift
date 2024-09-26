import UIKit
import FirebaseAuth


protocol ProfileCoordinatorDelegate: AnyObject {
    func presentEditProfileController(user: LetportsUser)
    func presentSettingViewController()
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String, teamColor: String)
    func didUpdateProfile()
    func backToGatheringDetail()
}

class ProfileCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    
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
        navigationController.dismiss(animated: true, completion: nil)
        parentCoordinator?.childDidFinish(self)
    }
    
    func presentGatheringDetailController(currentUser: LetportsUser, gatheringUid: String, teamColor: String) {
        let coordinator = GatheringDetailCoordinator(navigationController: navigationController, currentUser: currentUser, currentGatheringUid: gatheringUid, teamColor: teamColor)
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    func presentSettingViewController() {
        let coordinator = SettingCoodinator(navigationController: navigationController, viewModel: SettingVM())
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    func presentEditProfileController(user: LetportsUser) {
        let coordinator = ProfileEditCoordinator(navigationController: navigationController, viewModel: ProfileEditVM(user: user))
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.delegate = self
        coordinator.start()
    }
    
    func didUpdateProfile() {
        if let profileVC = navigationController.viewControllers.first(where: { $0 is ProfileVC }) as? ProfileVC {
            profileVC.reloadProfileData()
        }
    }
}
