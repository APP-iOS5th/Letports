//
//  GatherSettingCoordinator.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//

import UIKit
import Combine

protocol GatherSettingCoordinatorDelegate: AnyObject {
    func gatherSettingBackBtnTap()
}

class GatherSettingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]() {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var navigationController: UINavigationController
    var viewModel: GatherSettingVM
    weak var parentCoordinator: Coordinator?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController, gathering: Gathering) {
        self.navigationController = navigationController
        self.viewModel = GatherSettingVM(gathering: gathering)
        bindViewModel()
    }
    
    func start() {
        let profileVC = GatherSettingVC(viewModel: viewModel)
        viewModel.delegate = self
        navigationController.pushViewController(profileVC, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.alertPublisher
            .sink { [weak self] alertData in
                self?.presentAlert(title: alertData.title, message: alertData.message, confirmAction: alertData.confirmAction, cancelAction: alertData.cancelAction)
            }
            .store(in: &cancellables)
    }
    
    private func presentAlert(title: String, message: String, confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "확인", style: .destructive) { _ in
            confirmAction()
        }
        alert.addAction(confirm)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            cancelAction()
        }
        alert.addAction(cancel)
        
        navigationController.present(alert, animated: true, completion: nil)
    }
    
    private func presentSingleButtonAlert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alert.addAction(action)
        navigationController.present(alert, animated: true, completion: nil)
    }
}

extension GatherSettingCoordinator: GatherSettingCoordinatorDelegate {
    func gatherSettingBackBtnTap() {
        navigationController.popViewController(animated: true)
        self.parentCoordinator?.childDidFinish(self)
    }
}
