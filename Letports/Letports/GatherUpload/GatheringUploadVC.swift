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
        let cnv = CustomNavigationView(isLargeNavi: .small,
                                       screenType: .smallCreateGathering(btnName: .create))
        
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
                         SeparatorTVCell.self,
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
    
    let imagePickerController = UIImagePickerController()
    
    private var viewModel: GatheringUploadVM
    
    private let buttonTapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: GatheringUploadVM) {
        self.viewModel = GatheringUploadVM()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        setupTapGesture()
        setupDelegate()
        uploadDebounce()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Setup
    private func setupUI() {
        self.view.backgroundColor = .lpBackgroundWhite
        
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$selectedImage
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$addButtonEnable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enable in
                self?.navigationView.rightButtonIsEnable(enable)
            }
            .store(in: &cancellables)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupDelegate() {
        imagePickerController.delegate = self
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRectangle.height, right: 0)
                    self.tableView.scrollIndicatorInsets = self.tableView.contentInset
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.tableView.contentInset = .zero
                self.tableView.scrollIndicatorInsets = .zero
            }
        )
    }
    
    private func uploadDebounce() {
        buttonTapSubject
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.viewModel.gatheringUpload()
            }
            .store(in: &cancellables)
    }
}

extension GatheringUploadVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        buttonTapSubject.send(())
    }
    
    func sportsSelectButtonDidTap() {
        
    }
    
    func backButtonDidTap() {
        self.dismiss(animated: true)
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
                return cell
            }
        case .separator:
            if let cell: SeparatorTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configureCell(height: 3)
                return cell
            }
        case .uploadImage:
            if let cell: GatheringUplaodImageTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configureCell(image: viewModel.selectedImage)
                return cell
            }
        case .gatherName:
            if let cell: GatheringUplaodTitleTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                return cell
            }
        case .gatherMemberCount:
            if let cell: GatheringUploadMemCntTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                return cell
            }
        case .gatherInfo:
            if let cell: GatheringUploadInfoTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                return cell
            }
        case .gatherQuestion:
            if let cell: GatheringUploadQuestionTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension GatheringUploadVC: GatheringUploadDelegate {
    func didTapUploadImage() {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true)
    }
    
    func checkMemberCount(count: Int) {
        viewModel.checkMemeberMaxCount(count: count)
    }
    
    func sendGatehrInfo(content: String) {
        viewModel.writeGatherInfo(content: content)
    }
    
    func sendGatherQuestion(content: String) {
        viewModel.writeGatherQuestion(content: content)
    }
    
    func sendGatherName(content: String) {
        viewModel.writeGatehrName(content: content)
    }
}

extension GatheringUploadVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            viewModel.selectedImage = selectedImage
        }
    }
}
