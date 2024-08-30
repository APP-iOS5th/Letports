
import UIKit
import Combine
import FirebaseAuth
import GoogleSignIn

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        checkAuthAndTeamState()
    }
    
    func checkAuthAndTeamState() {
        if let currentUser = Auth.auth().currentUser {
            FM.getData(collection: "Users", document: currentUser.uid, type: LetportsUser.self)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error fetching user data: \(error)")
                        self.showAuthView()
                    case .finished:
                        break
                    }
                }, receiveValue: { user in
                    if user.userSports.isEmpty || user.userSportsTeam.isEmpty {
                        self.showTeamSelectionView()
                    } else {
                        self.showMainView()
                    }
                })
                .store(in: &cancellables)
        } else {
            showAuthView()
        }
    }
    
    func showAuthView() {
        navigationController.viewControllers.removeAll()
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        childCoordinators = [authCoordinator]
        authCoordinator.start()
    }
    
    func showTeamSelectionView() {
        navigationController.viewControllers.removeAll()
        let teamSelectionCoordinator = TeamSelectionCoordinator(navigationController: navigationController)
        teamSelectionCoordinator.parentCoordinator = self
        childCoordinators = [teamSelectionCoordinator]
        teamSelectionCoordinator.start()
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
