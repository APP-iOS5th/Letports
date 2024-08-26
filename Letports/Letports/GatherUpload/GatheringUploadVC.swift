//
//  GatheringUploadVC.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit
import Combine

protocol GatheringUploadDelegate: AnyObject {
    func didTapUploadImage()
    func checkMemberCount(count: Int)
    func sendGatherName(content: String)
    func sendGatehrInfo(content: String)
    func sendGatherQuestion(content: String)
}


class GatheringUploadVC: UIViewController {
    
    private(set) lazy var navigationView: CustomNavigationView = {
        let isEditMode = viewModel.isEditMode
        let screenType: ScreenType = .smallUploadGathering(btnName: viewModel.isEditMode ? .update : .create, 
                                                           isUpdate: viewModel.isEditMode)
        let cnv = CustomNavigationView(isLargeNavi: .small,
                                       screenType: screenType)
        
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.registersCell(cellClasses: GatheringUploadMainTVCell.self,
                         SeperatorLineTVCell.self,
                         GatheringUplaodImageTVCell.self,
                         GatheringUplaodTitleTVCell.self,
                         GatheringUploadMemCntTVCell.self,
                         GatheringUploadInfoTVCell.self,
                         GatheringUploadQuestionTVCell.self)
        tv.separatorStyle = .none
        tv.backgroundColor = .lp_background_white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var loadingIndicatorView: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    private var viewModel: GatheringUploadVM
    
    private let buttonTapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: GatheringUploadVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.bindViewModel()
        self.setupTapGesture()
        self.uploadDebounce()
        self.bindKeyboard()
    }
    
    //MARK: - Setup
    private func setupUI() {
        self.view.backgroundColor = .lpBackgroundWhite
        
        [navigationView, tableView, loadingIndicatorView].forEach {
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            loadingIndicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        self.viewModel.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        self.viewModel.$addButtonEnable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enable in
                self?.navigationView.rightButtonIsEnable(enable)
            }
            .store(in: &cancellables)
        
        self.viewModel.$isUploading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isUploading in
                if isUploading {
                    self?.loadingIndicatorView.startAnimating()
                } else {
                    self?.loadingIndicatorView.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    
    private func bindKeyboard() {
        // 키보드가 나타날 때의 이벤트를 구독
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink { [weak self] keyboardFrame in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.tableView.contentInset = UIEdgeInsets(top: 0,
                                                               left: 0,
                                                               bottom: keyboardFrame.height,
                                                               right: 0)
                    self.tableView.scrollIndicatorInsets = self.tableView.contentInset
                }
            }
            .store(in: &cancellables)
        
        // 키보드가 사라질 때의 이벤트를 구독
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.tableView.contentInset = .zero
                    self.tableView.scrollIndicatorInsets = .zero
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTapGesture() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func uploadDebounce() {
        self.buttonTapSubject
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.viewModel.gatheringUpload()
            }
            .store(in: &cancellables)
    }
}

extension GatheringUploadVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        self.buttonTapSubject.send(())
    }
    
    func sportsSelectButtonDidTap() {
        
    }
    
    func backButtonDidTap() {
        self.viewModel.didTapDismiss()
    }
}

extension GatheringUploadVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .main:
            if let cell: GatheringUploadMainTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configureCell(sportsTeam: self.viewModel.sportsTeam)
                return cell
            }
        case .separator:
            if let cell: SeperatorLineTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configureCell(height: 3)
                return cell
            }
        case .uploadImage:
            if let cell: GatheringUplaodImageTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configureCell(image: self.viewModel.selectedImage)
                return cell
            }
        case .gatherName:
            if let cell: GatheringUplaodTitleTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configureCell(title: self.viewModel.gatherNameText)
                return cell
            }
        case .gatherMemberCount:
            if let cell: GatheringUploadMemCntTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configureCell(nowCount: self.viewModel.memMaxCount)
                return cell
            }
        case .gatherInfo:
            if let cell: GatheringUploadInfoTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configureCell(infoText: self.viewModel.gatherInfoText)
                return cell
            }
        case .gatherQuestion:
            if let cell: GatheringUploadQuestionTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configureCell(question: self.viewModel.gatherQuestionText)
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension GatheringUploadVC: GatheringUploadDelegate {
    func didTapUploadImage() {
        self.viewModel.photoUploadButtonTapped()
    }
    
    func checkMemberCount(count: Int) {
        self.viewModel.checkMemeberMaxCount(count: count)
    }
    
    func sendGatehrInfo(content: String) {
        self.viewModel.writeGatherInfo(content: content)
    }
    
    func sendGatherQuestion(content: String) {
        self.viewModel.writeGatherQuestion(content: content)
    }
    
    func sendGatherName(content: String) {
        self.viewModel.writeGatehrName(content: content)
    }
}


