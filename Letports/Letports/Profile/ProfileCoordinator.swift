

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
        let profileVC = ProfileVC()
        profileVC.coordinator = self
        navigationController.pushViewController(profileVC, animated: false)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async { [weak self] in
                self?.parentCoordinator?.userDidLogout()
            }
        } catch let signOutError as NSError {
            print("ProfileCoordinator: Error signing out: \(signOutError)")
        }
    }
}
