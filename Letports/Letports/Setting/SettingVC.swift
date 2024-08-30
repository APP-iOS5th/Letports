//
//  ProfileVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit
import Combine
import Kingfisher

class SettingVC: UIViewController {
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(logoutBtnDidTap), for: .touchUpInside)
        return button
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .lp_background_white
        
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func logoutBtnDidTap() {
        do {
            try AuthService.shared.signOut()
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate,
               let appCoordinator = sceneDelegate.appCoordinator {
                appCoordinator.userDidLogout()
            }
        } catch {
            print("로그아웃 중 오류 발생: \(error.localizedDescription)")
        }
    }
}
