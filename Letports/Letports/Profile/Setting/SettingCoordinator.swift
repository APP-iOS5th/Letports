//
//  SettingCoordinator.swift
//  Letports
//
//  Created by mosi on 9/3/24.
//

import UIKit
import Combine

protocol SettingCoordinatorDelegate: AnyObject {
    func openLibraryDidTap()
    func presentBottomSheet(with url: URL)
    func logoutDidTap()
    func backToProfile()
    func backToAuthView()
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
//        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        viewModel.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
}

extension SettingCoodinator: SettingCoordinatorDelegate  {
    func openLibraryDidTap() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options:[:], completionHandler: nil)
            }
    }
    
    func presentBottomSheet(with url: URL) {
        let bottomSheetVC = URLVC(url: url)
        bottomSheetVC.modalPresentationStyle = .pageSheet
        
        let detentIdentifier = UISheetPresentationController.Detent.Identifier("customDetent")
        let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
            let screenHeight = UIScreen.main.bounds.height
            return screenHeight * 0.878912
        }
        
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [customDetent]
            sheet.preferredCornerRadius = 30
            sheet.prefersGrabberVisible = true
        }
        
        self.navigationController.present(bottomSheetVC, animated: true, completion: nil)
    }
    
    func logoutDidTap() {
        do {
            try AuthService.shared.signOut()
            self.backToAuthView()
        } catch {
            print("로그아웃 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func backToAuthView() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let appCoordinator = sceneDelegate.appCoordinator {
            appCoordinator.backToShowAuthView()
        }
    }
    
    func backToProfile() {
        self.navigationController.popViewController(animated: true)
        self.parentCoordinator?.childDidFinish(self)
    }
}
