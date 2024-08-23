//
//  ProfileEditVC.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//

import UIKit
import Combine
import Kingfisher


protocol ProfileEditDelegate: AnyObject {
    func didTapEditProfileImage()
    func editUserNickName(content: String)
    func editUserSimpleInfo(content: String)
}

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
        let view = CustomNavigationView(isLargeNavi: .small, screenType: .smallEditProfile(btnName: .save))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.registersCell(cellClasses: ProfileImageTVCell.self,
                         NickNameTVCell.self,
                         SimpleInfoTVCell.self)
        tv.backgroundColor = .lp_background_white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lp_background_white
        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        
    }
    
    private func bindViewModel() {
        Publishers.CombineLatest(
            viewModel.$user,
            viewModel.$selectedImage
        )
        .sink { [weak self] (user, selectedImage) in
            self?.tableView.reloadData()
        }
    }
    
}

extension ProfileEditVC: CustomNavigationDelegate {
    func backButtonDidTap() {
        self.viewModel.backToProfile()
    }
    
    func smallRightButtonDidTap() {
        print("데이터 저장해야함")
    }
}

extension ProfileEditVC: ProfileEditDelegate {
    
    func editUserNickName(content: String) {
        self.viewModel.editUserNickName(content: content)
    }
    
    func editUserSimpleInfo(content: String) {
        self.viewModel.editUserSimpleInfo(content: content)
    }
    
    
    func didTapEditProfileImage() {
        self.viewModel.photoUploadButtonTapped()
    }
}

extension ProfileEditVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .profileImage:
            return 150.0
        case .nickName:
            return 80.0
        case .simpleInfo:
            return 80.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .profileImage:
            if let cell: ProfileImageTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configure(with: viewModel)
                //cell.configure(with: viewModel.user?.image)
                return cell
            }
        case .nickName:
            if let cell: NickNameTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(with: viewModel.user?.nickname ?? "")
                return cell
            }
        case .simpleInfo:
            if let cell: SimpleInfoTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(with: viewModel.user?.simpleInfo ?? "")
                return cell
            }
        }
        return UITableViewCell()
    }
    
}
