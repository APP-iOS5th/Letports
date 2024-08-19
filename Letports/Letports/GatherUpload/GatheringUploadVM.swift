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

    private var memMaxCount: Int = 1
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
    
    func uploadImage() -> AnyPublisher<String?, Never> {
        guard let image = selectedImage else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return FirebaseStorageManager.uploadImages(images: [image], filePath: .gatherImageUpload)
            .map { urls in
                urls.first?.absoluteString
            }
            .catch { error -> Just<String?> in
                print(error.localizedDescription)
                return Just(nil)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    func getCellTypes() -> [BoardUploadCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func checkMemeberMaxCount(count: Int) {
        self.memMaxCount = count
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
    
    func gatheringUpload() {
        uploadImage()
            .sink { [weak self] imageUrl in
                guard let self = self else { return }
                self.gatehringUpload(imageUrl: imageUrl ?? "")
            }
            .store(in: &cancellables)
    }
    

    func gatehringUpload(imageUrl: String) {
        if let gatehrName = gatehrNameText,
           let gatherInfo = gatehrInfoText,
           let gatherQuestion = gatehrQuestionText {
            
            let uuid = UUID().uuidString
            
            let gathering = Gathering(gatheringSports: "축구", gatheringTeam: "테스트",
                                      gatheringUID: uuid,
                                      gatheringMaster: "나",
                                      gatheringName: gatehrName, gatheringImage: imageUrl,
                                      gatherMaxMember: memMaxCount, gatherNowMember: 1,
                                      gatherInfo: gatherInfo, gatherQuestion: gatherQuestion,
                                      gatheringMembers: ["나"],
                                      gatheringCreateDate: Date())
            
            FM.setData(collection: "Gathering", document: uuid, data: gathering)
                .sink { _ in
                } receiveValue: {
                    print("Data Save")
                }
                .store(in: &cancellables)
        }
    }
}
