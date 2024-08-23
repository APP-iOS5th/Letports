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
    
    private var cellType: [ProfileEditCellType] {
        var cellTypes: [ProfileEditCellType] = []
        cellTypes.append(.profileImage)
        cellTypes.append(.nickName)
        cellTypes.append(.simpleInfo)
        return cellTypes
    }
    
    func getCellTypes() -> [ProfileEditCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    weak var delegate: ProfileEditCoordinatorDelegate?
    
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
    
    init(user: LetportsUser?) {
        self.user = user
        self.loadImage(from: user?.image ?? "")
    }

    private func loadImage(from urlString: String) {
        guard selectedImage == nil else { return }
        // URL 문자열을 URL 객체로 변환
        guard let url = URL(string: urlString) else { return }
        
        // URLSession의 dataTaskPublisher를 사용하여 이미지 데이터를 비동기적으로 가져옴
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in
                UIImage(data: data) // 데이터를 UIImage로 변환
            }
            .replaceError(with: nil) // 오류 발생 시 nil로 대체
            .sink { [weak self] image in
                // 이미지를 처리 (예: boardPhoto에 저장)
                self?.selectedImage = image
            }
            .store(in: &cancellables) // Cancellable을 저장하여 구독 유지
    }
}


