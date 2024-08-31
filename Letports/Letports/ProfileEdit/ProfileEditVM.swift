//
//  ProfileEditVM.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//

import Combine
import UIKit
import Kingfisher

enum ProfileEditCellType {
    case profileImage
    case nickName
    case simpleInfo
}

class ProfileEditVM {
    @Published var user: LetportsUser?
    @Published var selectedImage: UIImage?
    @Published private(set) var usernickName: String?
    @Published private(set) var userSimpleInfo: String?
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: ProfileEditCoordinatorDelegate?
    
    private var cellType: [ProfileEditCellType] {
        var cellTypes: [ProfileEditCellType] = []
        cellTypes.append(.profileImage)
        cellTypes.append(.nickName)
        cellTypes.append(.simpleInfo)
        return cellTypes
    }
    
    init(user: LetportsUser?) {
        self.user = user
        self.loadImage(urlString: user?.image ?? "")
    }
    
    func getCellTypes() -> [ProfileEditCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func editUserNickName(content: String) {
        self.usernickName = content
    }
    
    func editUserSimpleInfo(content: String) {
        self.userSimpleInfo = content
    }
    
    func changeSelectedImage(selectedImage: UIImage) {
        self.selectedImage = selectedImage
    }
    
    func didTapDismiss() {
        self.delegate?.dismissViewController()
    }
    
    func backToProfile() {
        self.delegate?.backToProfileViewController()
    }
    
    func photoUploadButtonTapped() {
        self.delegate?.presentImagePickerController()
    }
    
    private func loadImage(urlString: String) {
        guard selectedImage == nil else { return }
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in
                UIImage(data: data)
            }
            .replaceError(with: nil)
            .sink { [weak self] image in
                self?.selectedImage = image
            }
            .store(in: &cancellables)
    }
}


