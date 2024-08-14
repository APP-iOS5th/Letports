//
//  BoaderEditorVC.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import UIKit
import Combine
import Photos

class BoaderEditorVC: UIViewController {
    private(set) lazy var navigationView: CustomNavigationView = {
        let cnv = CustomNavigationView(isLargeNavi: .small,
                                       screenType: .smallBoardEditor(btnName: .write, isUpload: true))
        
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.registersCell(cellClasses: BoaderEditorTitleTVCell.self,
                         BoaderEditorContentTVCell.self,
                         BoaderEditorPhotoTVCell.self)
        
        tv.separatorStyle = .none
        tv.backgroundColor = .lp_background_white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var viewModel: BoaderEditorVM
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: BoaderEditorVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapGesture()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), 
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), 
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Setup
    private func setupUI() {
        self.view.backgroundColor = .lp_background_white
        
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
        viewModel.$addButtonEnable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enable in
                self?.navigationView.rightButtonIsEnable(enable)
            }
            .store(in: &cancellables)
        
        viewModel.$boardPhotos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
                    self.tableView.contentInset = UIEdgeInsets(top: 0, 
                                                               left: 0,
                                                               bottom: keyboardRectangle.height,
                                                               right: 0)
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
}

extension BoaderEditorVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        
    }
    
    func sportsSelectButtonDidTap() {
        
    }
    
    func backButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension BoaderEditorVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.viewModel.getCellTypes()[indexPath.row] {
            
        case .title:
            if let cell: BoaderEditorTitleTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                return cell
            }
        case .content:
            if let cell: BoaderEditorContentTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                return cell
            }
        case .photo:
            if let cell: BoaderEditorPhotoTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configureCell(photos: viewModel.boardPhotos)
                return cell
            }
        }
        return UITableViewCell()
    }
}


extension BoaderEditorVC: BoardEditorCellDelegate {
    func addPhoto(image: UIImage) {
        viewModel.addBoardPhotos(photo: image)
    }
    
    func deletePhoto(index: Int) {
        viewModel.deleteBoardPhoto(index: index)
    }
    
    func writeTitle(content: String) {
        viewModel.writeBoardTitle(content: content)
    }
    
    func writeContent(content: String) {
        viewModel.writeBoardContents(content: content)
    }
    
    func presentImagePickerController() {
        self.selectPhotoButtonTapped()
    }
}

extension BoaderEditorVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    private func selectPhotoButtonTapped() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    self?.presentImagePC()
                } else {
                    self?.showAccessDeniedAlert()
                }
            }
        case .authorized, .limited:
            presentImagePC()
        case .denied, .restricted:
            showAccessDeniedAlert()
        @unknown default:
            showAccessDeniedAlert()
        }
    }
    
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "앨범 접근 권한 필요", 
                                      message: "설정에서 앨범 접근 권한을 허용해주세요.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func presentImagePC() {
        DispatchQueue.main.async {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, 
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            viewModel.addBoardPhotos(photo: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

#Preview() {
    BoaderEditorVC(viewModel: BoaderEditorVM())
}
