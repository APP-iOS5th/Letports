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
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var loadingIndicatorView: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
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
        [navigationView, tableView, loadingIndicatorView].forEach {
            self.view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        let mergedPublishers = Publishers.Merge(
            viewModel.$user.map { _ in () }.eraseToAnyPublisher(),
            viewModel.$selectedImage.map { _ in () }.eraseToAnyPublisher()
        )
        mergedPublishers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                let indexPathsToUpdate = self.viewModel.getCellTypes().enumerated().compactMap { index, type in
                    return type == .profileImage ? IndexPath(row: index, section: 0) : nil
                }
                if !indexPathsToUpdate.isEmpty {
                    self.tableView.reloadRows(at: indexPathsToUpdate, with: .automatic)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.navigationView.rightBtnIsEnable(isValid)
            }
            .store(in: &cancellables)
        
        self.viewModel.$isUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isUpdate in
                if isUpdate {
                    self?.loadingIndicatorView.startAnimating()
                } else {
                    self?.loadingIndicatorView.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func moveToNextCell(from indexPath: IndexPath) {
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        if let nextCell = tableView.cellForRow(at: nextIndexPath) as? NickNameTVCell {
            nextCell.nickNameTextField.becomeFirstResponder()
        } else if let nextCell = tableView.cellForRow(at: nextIndexPath) as? SimpleInfoTVCell {
            nextCell.simpleInfoTextField.becomeFirstResponder()
        }
    }
}

extension ProfileEditVC: CustomNavigationDelegate {
    func backBtnDidTap() {
        self.viewModel.backToProfile()
    }
    
    func smallRightBtnDidTap() {
        viewModel.profileUpdate()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
//                    self?.showAlert(title: "성공", message: "프로필이 성공적으로 업데이트되었습니다.") {
                        self?.viewModel.updateProfile()
//                    }
                case .failure(let error):
                    self?.showAlert(title: "오류", message: "\(error.localizedDescription)") {
                    }
                }
            }, receiveValue: {
                print("Profile updated successfully.")
            })
            .store(in: &cancellables)
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
        self.viewModel.photoUploadBtnDidTap()
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
        case .nickName, .simpleInfo:
            return 120.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .profileImage:
            if let cell: ProfileImageTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configure(with: viewModel.selectedImage)
                return cell
            }
        case .nickName:
            if let cell: NickNameTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(with: viewModel.user?.nickname ?? "")
                cell.delegate = self
                cell.moveToNextTextField = { [weak self] in
                    self?.moveToNextCell(from: indexPath)
                }
                return cell
            }
        case .simpleInfo:
            if let cell: SimpleInfoTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(with: viewModel.user?.simpleInfo ?? "")
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
}
