//
//  GatheringBoardUploadCoordinaotr.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import Foundation
import UIKit
import Photos

protocol GatheringUploadCoordinatorDelegate: AnyObject {
    func dismissViewController()
    func presentImagePickerController()
}

class GatheringUploadCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = [] {
        didSet {
            let fileName = (#file as NSString).lastPathComponent
            print("\(fileName) child coordinators:: \(childCoordinators)")
        }
    }
    var viewModel: GatheringUploadVM
    weak var delegate: GatheringCoordinatorDelegate?
    
    init(navigationController: UINavigationController, viewModel: GatheringUploadVM) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func start() {
        viewModel.delegate = self
        let vc = GatheringUploadVC(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        navigationController.present(vc, animated: true)
    }
    
    func imagePickerPresent() {
        DispatchQueue.main.async {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            if let topViewController = self.topMostViewController() {
                topViewController.present(imagePickerController, animated: true)
            } else {
                print("No topViewController found")
            }
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
        // 활성화된 UIWindowScene을 찾습니다.
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            return nil
        }
        
        // 해당 UIWindowScene에서 topViewController를 찾습니다.
        var topViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
}


extension GatheringUploadCoordinator: GatheringUploadCoordinatorDelegate {
    func dismissViewController() {
        self.navigationController.dismiss(animated: true)
        self.parentCoordinator?.childDidFinish(self)
        delegate?.endUploadGathering()
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

extension GatheringUploadCoordinator: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
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
