//
//  BoardEditorVM.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import Foundation
import UIKit
import Combine
import FirebaseAuth

enum BoardEditorCellType {
    case title
    case content
    case photo
}

protocol BoardEditorDelegate: AnyObject {
    func writeTitle(content: String)
    func writeContent(content: String)
    func didTapAddPhotoButton()
    func didTapDeletePhotoButton(photoIndex: Int)
}


class BoardEditorVM {
    
    @Published private(set) var addButtonEnable: Bool = true
    @Published private(set) var boardTitle: String?
    @Published private(set) var boardContents: String?
    @Published private(set) var boardPhotos: [UIImage] = []
    @Published private(set) var isUploading: Bool = false
    
    private(set) var postType: PostType = .free
    private(set) var gathering: Gathering?
    
    
    private(set) var isEditMode: Bool
    private var postID: String?
    private var cancellables = Set<AnyCancellable>()
    
    
    weak var delegate: BoardEditorCoordinatorDelegate?
    
    private var cellType: [BoardEditorCellType] {
        var cellTypes: [BoardEditorCellType] = []
        cellTypes.append(.title)
        cellTypes.append(.content)
        cellTypes.append(.photo)
        return cellTypes
    }
    
    init(type: PostType, gathering: Gathering, post: Post? = nil) {
        if let post = post {
            self.isEditMode = true
            self.postID = post.postUID
            self.boardTitle = post.title
            self.boardContents = post.contents
            self.loadImages(from: post.imageUrls)
        } else {
            self.isEditMode = false
        }
        self.gathering = gathering
        self.postType = type
        
        Publishers.CombineLatest($boardTitle, $boardContents)
            .map { boardTitle, boardContents in
                return boardTitle != nil && boardContents != nil
            }
            .assign(to: \.addButtonEnable, on: self)
            .store(in: &cancellables)
    }
    
    func boardUpload() {
        guard !isUploading else { return }
        self.isUploading = true
        
        uploadImage()
            .sink { [weak self] imageUrls in
                guard let self = self else { return }
                if imageUrls.isEmpty {
                    self.isUploading = false
                } else {
                    self.boardUpload(images: imageUrls)
                }
            }
            .store(in: &cancellables)
    }
    
    private func uploadImage() -> AnyPublisher<[String], Never> {
        return FirebaseStorageManager.uploadImages(images: boardPhotos, filePath: .boardImageUpload)
            .map { urls in
                return urls.map { $0.absoluteString }
            }
            .catch { error -> Just<[String]> in
                print("Error occurred during image upload: \(error.localizedDescription)")
                return Just([])
            }
            .eraseToAnyPublisher()
    }
    
    
    private func boardUpload(images: [String]) {
        if let title = boardTitle,
           let contents = boardContents,
           let gatheringUid = gathering?.gatheringUid{
            
            let boardUuid = UUID().uuidString
            guard let myUserUid = Auth.auth().currentUser?.uid else { return }
            
            
            let post = Post(postUID: self.isEditMode ? self.postID ?? boardUuid : boardUuid,
                            userUID: myUserUid,
                            title: title, contents: contents,
                            imageUrls: images, boardType: self.postType)
            
            
            let collectionPath: [FirestorePathComponent] = [
                .collection(.gatherings),
                .document(gatheringUid),
                .collection(.board),
                .document(post.postUID)
            ]
            
            if isEditMode {
                let updateContentFields: [String: Any] = [
                    "title": title,
                    "contents": contents
                ]
                FM.updateData(pathComponents: collectionPath, fields: updateContentFields)
                    .sink { _ in
                    } receiveValue: { [weak self] _ in
                        self?.isUploading = false
                        self?.delegate?.popViewController()
                    }
                    .store(in: &cancellables)
            } else {
                FM.setData(pathComponents: collectionPath, data: post)
                    .sink { _ in
                    } receiveValue: { [weak self] _ in
                        self?.isUploading = false
                        self?.delegate?.popViewController()
                    }
                    .store(in: &cancellables)
            }
            
        }
    }
    
    private func loadImages(from urls: [String]) {
        let imagePublishers = urls.compactMap { urlString -> AnyPublisher<UIImage?, Never>? in
            guard let url = URL(string: urlString) else { return nil }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in
                    UIImage(data: data)
                }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(imagePublishers)
            .collect()
            .sink { [weak self] images in
                self?.boardPhotos = images.compactMap { $0 }
            }
            .store(in: &cancellables)
    }
    
    
    func photoUploadButtonTapped() {
        self.delegate?.photoUploadButtonTapped()
    }
    
    func backButtonTapped() {
        self.delegate?.popViewController()
    }
    
    //MARK: - OutPut
    func getCellTypes() -> [BoardEditorCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func getPhotoCount() -> Int {
        return self.isEditMode ? self.boardPhotos.count : self.boardPhotos.count + 1
    }
    
    func photoUploadIsLimit() -> Bool {
        return self.boardPhotos.count < 5 ? false : true
    }
    
    //MARK: - Input
    func writeBoardTitle(content: String) {
        self.boardTitle = content
    }
    
    func writeBoardContents(content: String) {
        self.boardContents = content
    }
    
    func addBoardPhotos(photo: UIImage) {
        self.boardPhotos.append(photo)
    }
    
    func deleteBoardPhoto(index: Int) {
        self.boardPhotos.remove(at: index - 1)
    }
    
    
}
