//
//  BoarderEditorVM.swift
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


class BoarderEditorVM {
    
    @Published var addButtonEnable: Bool = true
    @Published var boardTitle: String?
    @Published var boardContents: String?
    @Published var boardPhotos: [UIImage] = []
    
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
