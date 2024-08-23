//
//  ProfileEditCoordinator.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//
import UIKit
import Photos

protocol ProfileEditCoordinatorDelegate: AnyObject {
    func dismissViewController()
    func presentImagePickerController()
    func backToProfileViewController()
}

class ProfileEditCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var viewModel: ProfileEditVM
    
    init(navigationController: UINavigationController , viewModel: ProfileEditVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        viewModel.delegate = self
        let profileEditVC = ProfileEditVC(viewModel: viewModel)
        navigationController.pushViewController(profileEditVC, animated: true)
    }
    
    func imagePickerPresent() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        if let topViewController = topMostViewController() {
            topViewController.present(imagePickerController, animated: true)
        } else {
            print("No topViewController found")
        }
    }
    
    func albumAccessDeniedAlert() {
        let alert = UIAlertController(title: "앨범 접근 권한 필요",
                                      message: "설정에서 앨범 접근 권한을 허용해주세요.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        navigationController.present(alert, animated: true)
    }
    
    func topMostViewController() -> UIViewController? {
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            return nil
        }
        
        var topViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}


extension ProfileEditCoordinator: ProfileEditCoordinatorDelegate {
    func dismissViewController() {
        self.navigationController.dismiss(animated: true)
    }
    
    func backToProfileViewController() {
        self.navigationController.popViewController(animated: true)
    }
    
    func presentImagePickerController() {
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
}

extension ProfileEditCoordinator: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            viewModel.changeSelectedImage(selectedImage: selectedImage)
        }
        picker.dismiss(animated: true)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
