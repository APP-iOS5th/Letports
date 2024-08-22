

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    weak var coordinator: ProfileCoordinator?
    
    private lazy var logoutBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.addTarget(self, action: #selector(logoutBtnTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .lpBackgroundWhite
        view.addSubview(logoutBtn)
        
        NSLayoutConstraint.activate([
            logoutBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func logoutBtnTapped() {
        showLogoutConfirmAlert()
    }
    
    private func showLogoutConfirmAlert() {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        
        let cancleAction = UIAlertAction(title: "취소", style: .cancel)
        
        let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.coordinator?.logout()
        }
        
        alert.addAction(cancleAction)
        alert.addAction(logoutAction)
        
        present(alert, animated: true)
    }
}
