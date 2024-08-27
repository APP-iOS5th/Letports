//
//  HomeVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class HomeVC: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.lpTint, for: .normal)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lpBackgroundWhite
        setupLogoutButton()
    }
    
    private func setupLogoutButton() {
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func logoutButtonTapped() {
        let alertController = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func performLogout() {
        do {
            try AuthService.shared.signOut()
            coordinator?.parentCoordinator?.userDidLogout()
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
            // 사용자에게 오류 메시지를 표시할 수 있습니다.
        }
    }
}
