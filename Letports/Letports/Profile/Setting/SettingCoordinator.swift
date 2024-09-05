//
//  SettingCoordinator.swift
//  Letports
//
//  Created by mosi on 9/3/24.
//

import UIKit
import Combine

protocol SettingCoordinatorDelegate: AnyObject {
    func toggleDidtap()
    func appTermsofServiceDidTap()
    func openLibraryDidTap()
    func appInfoDidTap()
    func logoutDidTap()
    func backToProfile()
}

class SettingCoodinator : Coordinator {
    var childCoordinators = [Coordinator]() {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    var viewModel : SettingVM
    
    init(navigationController: UINavigationController, viewModel: SettingVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        let vc = SettingVC(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        viewModel.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
}

extension SettingCoodinator: SettingCoordinatorDelegate  {
    func toggleDidtap() {
        print("테스트")
    }
    
    func appTermsofServiceDidTap() {
        print("앱 사용약관")
    }
    
    func openLibraryDidTap() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options:[:], completionHandler: nil)
            }
    }
    
    func appInfoDidTap() {
        print("앱 정보")
    }
    
    func logoutDidTap() {
        do {
            try AuthService.shared.signOut()
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let appCoordinator = sceneDelegate.appCoordinator {
                appCoordinator.userDidLogout()
            }
        } catch {
            print("로그아웃 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func backToProfile() {
        self.navigationController.popViewController(animated: true)
        self.parentCoordinator?.childDidFinish(self)
    }
}
