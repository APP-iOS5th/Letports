//
//  BoardEditorCoordinator.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import Foundation
import UIKit
import Photos

protocol BoardEditorCoordinatorDelegate: AnyObject {
    func photoUploadButtonTapped()
    func popViewController()
}

class BoardEditorCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    private var viewModel: BoardEditorVM
    
    init(navigationController: UINavigationController, viewModel: BoardEditorVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        self.viewModel.delegate = self
        let vc = BoardEditorVC(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func imagePickerPresent() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.navigationController.present(imagePickerController, animated: true)
    }
    
    func albumAccessDeniedAlert() {
        let alert = UIAlertController(title: "앨범 접근 권한 필요",
                                      message: "설정에서 앨범 접근 권한을 허용해주세요.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.navigationController.present(alert, animated: true)
    }
}


extension BoardEditorCoordinator: BoardEditorCoordinatorDelegate {
    func photoUploadButtonTapped() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    self?.imagePickerPresent()
                } else {
                    self?.albumAccessDeniedAlert()
                }
            }
        case .authorized, .limited:
            self.imagePickerPresent()
        case .denied, .restricted:
            self.albumAccessDeniedAlert()
        @unknown default:
            self.albumAccessDeniedAlert()
        }
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}

extension BoardEditorCoordinator: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, 
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.viewModel.addBoardPhotos(photo: selectedImage)
        }
        picker.dismiss(animated: true)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }   
}
