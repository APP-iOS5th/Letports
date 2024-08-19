//
//  BoardEditorVM.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import Foundation
import UIKit
import Combine

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
    
    @Published var addButtonEnable: Bool = true
    @Published var boardTitle: String?
    @Published var boardContents: String?
    @Published var boardPhotos: [UIImage] = []
    @Published var isUploading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private var cellType: [BoardEditorCellType] {
        var cellTypes: [BoardEditorCellType] = []
        cellTypes.append(.title)
        cellTypes.append(.content)
        cellTypes.append(.photo)
        return cellTypes
    }
    
    init() {
        Publishers.CombineLatest($boardTitle, $boardContents)
            .map { boardTitle, boardContents in
                return boardTitle != nil && boardContents != nil
            }
            .assign(to: \.addButtonEnable, on: self)
            .store(in: &cancellables)
    }
    
    func boardUpload() {
        guard !isUploading else { return }
        isUploading = true
        
        uploadImage()
            .sink { [weak self] imageUrls in
                guard let self = self else { return }
                self.boardUpload(images: imageUrls)
            }
            .store(in: &cancellables)
    }
    
    private func uploadImage() -> AnyPublisher<[String], Never> {
        return FirebaseStorageManager.uploadImages(images: boardPhotos, filePath: .boardImageUpload)
            .map { urls in
                urls.map { $0.absoluteString }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    
    private func boardUpload(images: [String]) {
        if let title = boardTitle,
           let contents = boardContents {
            let uuid = UUID().uuidString
            let post = Post(postUID: uuid, userUID: "몰루", title: title, contents: contents, 
                            imageUrls: images, comments: [], boardType: "Free")
            
            FM.setData(collection: "Board", document: uuid, data: post)
                .sink{ _ in
                } receiveValue: { [weak self] _ in
                    print("Data Save")
                    self?.isUploading = false
                }
                .store(in: &cancellables)
        }
    }
    
    //MARK: - OutPut
    func getCellTypes() -> [BoardEditorCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func getPhotoCount() -> Int {
        return self.boardPhotos.count + 1
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
        self.boardPhotos.remove(at: index)
    }
    
    
}
