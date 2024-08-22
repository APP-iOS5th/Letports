
import UIKit
import FirebaseAuth
import GoogleSignIn

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        checkAuthState()
    }
    
    func checkAuthState() {
        if Auth.auth().currentUser != nil {
            showMainView()
        } else {
            showAuthView()
        }
    }
    
    func showAuthView() {
        navigationController.viewControllers.removeAll()
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.parentCoordinator = self
        childCoordinators = [loginCoordinator]
        loginCoordinator.start()
    }
    
    func showMainView() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.parentCoordinator = self
        childCoordinators = [tabBarCoordinator]
        tabBarCoordinator.start()
    }
    
    func userDidLogout() {
        DispatchQueue.main.async { [weak self] in
            self?.showAuthView()
        }
    }
    
    func handleURL(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
}
