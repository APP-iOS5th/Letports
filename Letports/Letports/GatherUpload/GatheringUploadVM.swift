//
//  GatheringUploadVM.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import Foundation
import UIKit
import Combine

enum BoardUploadCellType {
    case main
    case uploadImage
    case gatherName
    case gatherMemberCount
    case gatherInfo
    case gatherQuestion
    case separator
}


class GatheringUploadVM {
    
    @Published var selectedImage: UIImage?
    @Published var addButtonEnable: Bool = true
    @Published var gatehrInfoText: String?
    @Published var gatehrQuestionText: String?
    @Published var gatehrNameText: String?
    
    private var memNowCount: Int = 1
    private var cancellables = Set<AnyCancellable>()
    
    private var cellType: [BoardUploadCellType] {
        var cellTypes: [BoardUploadCellType] = []
        cellTypes.append(.main)
        cellTypes.append(.separator)
        cellTypes.append(.uploadImage)
        cellTypes.append(.separator)
        cellTypes.append(.gatherName)
        cellTypes.append(.separator)
        cellTypes.append(.gatherMemberCount)
        cellTypes.append(.separator)
        cellTypes.append(.gatherInfo)
        cellTypes.append(.separator)
        cellTypes.append(.gatherQuestion)
        
        return cellTypes
    }
    
    
    init() {
         Publishers.CombineLatest4($selectedImage, $gatehrInfoText, $gatehrQuestionText, $gatehrNameText)
             .map { selectedImage, gatehrInfoText, gatehrQuestionText, gatehrNameText in
                 return selectedImage != nil
                 && gatehrInfoText != nil
                 && gatehrQuestionText != nil
                 && gatehrNameText != nil
             }
             .assign(to: \.addButtonEnable, on: self)
             .store(in: &cancellables)
     }
    
    
    func getCellTypes() -> [BoardUploadCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func checkMemeberCount(count: Int) {
        self.memNowCount = count
    }
    
    func writeGatherInfo(content: String) {
        self.gatehrInfoText = content
    }
    
    func writeGatherQuestion(content: String) {
        self.gatehrQuestionText = content
    }
    
    func writeGatehrName(content: String) {
        self.gatehrNameText = content
    }
}
