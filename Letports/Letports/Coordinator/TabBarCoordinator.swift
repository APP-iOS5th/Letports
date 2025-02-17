//
//  Coordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class TabBarCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var navigationController: UINavigationController
    
    let tabBarController: UITabBarController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        self.navigationController.isNavigationBarHidden = true
    }
    
    func start() {
        
        let homeNavController = UINavigationController()
        let gatheringNavController = UINavigationController()
        let profileNavController = UINavigationController()
        
		let homeCoordinator = HomeCoordinator(navigationController: homeNavController, viewModel: HomeViewModel())
		let gatheringCoordinator = GatheringCoordinator(navigationController: gatheringNavController, viewModel: GatheringVM())
        let profileCoordinator = ProfileCoordinator(navigationController: profileNavController, viewModel: ProfileVM(profileType: .myProfile, userUID: ""))
        
        homeCoordinator.parentCoordinator = self
        gatheringCoordinator.parentCoordinator = self
        profileCoordinator.parentCoordinator = self
        
        childCoordinators = [homeCoordinator, gatheringCoordinator, profileCoordinator]
        
        homeCoordinator.start()
        gatheringCoordinator.start()
        profileCoordinator.start()
        
        tabBarController.viewControllers = [homeNavController, gatheringNavController, profileNavController]
        
        setupTabBar()
        
        navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    private func setupTabBar() {
        guard let items = tabBarController.tabBar.items else { return }
        
        let homeTab = items[0]
        homeTab.title = "홈"
        homeTab.image = UIImage(systemName: "house")
        homeTab.selectedImage = UIImage(systemName: "house.fill")
        
        let gatheringTab = items[1]
        gatheringTab.title = "소모임"
        gatheringTab.image = UIImage(systemName: "person.3")
        gatheringTab.selectedImage = UIImage(systemName: "person.3.fill")
        
        let profileTab = items[2]
        profileTab.title = "프로필"
        profileTab.image = UIImage(systemName: "person")
        profileTab.selectedImage = UIImage(systemName: "person.fill")
        
        tabBarController.tabBar.tintColor = .lpMain
        tabBarController.tabBar.backgroundColor = .lpBackgroundWhite
    }
    
    func userDidLogout() {
        (parentCoordinator as? AppCoordinator)?.backToShowAuthView()
    }
}
