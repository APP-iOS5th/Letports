//
//  ProfileEditVC.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//

import UIKit
import Combine

class ProfileEditVC: UIViewController {
    private var viewModel: ProfileEditVM
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ProfileEditVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var navigationView: CustomNavigationView = {
        let btnName: NaviButtonType
        let view = CustomNavigationView(isLargeNavi: .small)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileEditView: ProfileEditView = {
        let view = ProfileEditView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lp_background_white
        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        view.addSubview(profileEditView)
        view.addSubview(navigationView)
        profileEditView.profileImageButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 90),
            profileEditView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileEditView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            profileEditView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            profileEditView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        
    }
    
    private func bindViewModel() {
        viewModel.$user
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                guard let self = self, let user = user else { return }
                self.profileEditView.nickNameTextField.text = user.nickname
                self.profileEditView.simpleInfoTextField.text = user.simpleInfo
            }
            .store(in: &cancellables)
        
        
    }
    
    @objc private func profileImageButtonTapped() {
        //        coordinator?.showImagePickerController()
    }
    
    
    
}



extension ProfileEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    
    
}
