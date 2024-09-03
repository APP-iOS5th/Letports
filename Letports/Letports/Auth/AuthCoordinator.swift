

import UIKit

class AuthCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let authService = AuthService.shared
        let viewModel = AuthVM()
        viewModel.loginSuccess = { [weak self] in
            DispatchQueue.main.async {
                (self?.parentCoordinator as? AppCoordinator)?.checkAuthAndTeamState()
            }
        }
        viewModel.loginFailure = { error in
            print("AuthCoordinator: Login failed: \(error.localizedDescription)")
        }
        
        let authVC = AuthVC(viewModel: viewModel, authService: authService)
        navigationController.setViewControllers([authVC], animated: true)
    }
}
