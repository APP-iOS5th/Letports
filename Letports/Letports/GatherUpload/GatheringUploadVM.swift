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
    let sportsTeam = SampleSportsTeam(
        sportsUID: "I5umvrhFTwzeOkYlgvL3",
        teamHomeTown: "서울특별시",
        teamLogo: "https://www.kleague.com/assets/images/emblem/emblem_K09.png",
        teamName: "FC서울",
        teamStadium: "서울월드컵경기장",
        teamStartDate: "1983",
        teamUID: "YcXsJAgoFtqS3XZ0HdZu"
    )
    
    @Published private(set) var selectedImage: UIImage?
    @Published private(set) var addButtonEnable: Bool = true
    @Published private(set) var gatherInfoText: String?
    @Published private(set) var gatherQuestionText: String?
    @Published private(set) var gatherNameText: String?
    @Published private(set) var isUploading: Bool = false
    
    private(set) var isEditMode: Bool
    private var gatehringID: String?
    
    private(set) var memMaxCount: Int = 1
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: GatheringUploadCoordinatorDelegate?
    
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
    
    
    init(gathering: SampleGathering2? = nil) {
        if let gathering = gathering {
            self.isEditMode = true
            self.gatehringID = gathering.gatheringUid
            self.gatherNameText = gathering.gatherName
            self.gatherInfoText = gathering.gatherInfo
            self.gatherQuestionText = gathering.gatherQuestion
            self.memMaxCount = gathering.gatherMaxMember
            
            self.loadImage(from: gathering.gatherImage)
                .sink { [weak self] image in
                    self?.selectedImage = image
                }
                .store(in: &cancellables)
        } else {
            self.isEditMode = false
        }
        
        Publishers.CombineLatest4($selectedImage, $gatherInfoText, $gatherQuestionText, $gatherNameText)
            .map { selectedImage, gatehrInfoText, gatherQuestionText, gatherNameText in
                return selectedImage != nil
                && gatehrInfoText != nil
                && gatherQuestionText != nil
                && gatherNameText != nil
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
    
    func checkMemeberMaxCount(count: Int) {
        self.memMaxCount = count
    }
    
    func writeGatherInfo(content: String) {
        self.gatherInfoText = content
    }
    
    func writeGatherQuestion(content: String) {
        self.gatherQuestionText = content
    }
    
    func writeGatehrName(content: String) {
        self.gatherNameText = content
    }
    
    func changeSelectedImage(selectedImage: UIImage) {
        self.selectedImage = selectedImage
    }
    
    func didTapDismiss() {
        self.delegate?.dismissViewController()
    }
    
    func photoUploadButtonTapped() {
        self.delegate?.presentImagePickerController()
    }
    
    func gatheringUpload() {
        guard !isUploading else { return }
        isUploading = true
        
        uploadImage()
            .sink { [weak self] imageUrl in
                guard let self = self else { return }
                self.gatehringUpload(imageUrl: imageUrl ?? "")
                self.delegate?.dismissViewController()
            }
            .store(in: &cancellables)
    }
    
    private func uploadImage() -> AnyPublisher<String?, Never> {
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
    
    
    
    private func gatehringUpload(imageUrl: String) {
        if let gatherName = gatherNameText,
           let gatherInfo = gatherInfoText,
           let gatherQuestion = gatherQuestionText {
            
            let uuid = UUID().uuidString
            
            let gathering = SampleGathering(gatheringSports: "축구", gatheringTeam: "테스트",
                                            gatheringUID: self.isEditMode ? self.gatehringID ?? uuid : uuid,
                                            gatheringMaster: "나",
                                            gatheringName: gatherName, gatheringImage: imageUrl,
                                            gatherMaxMember: memMaxCount, gatherNowMember: 1,
                                            gatherInfo: gatherInfo, gatherQuestion: gatherQuestion,
                                            gatheringMembers: [],
                                            gatheringCreateDate: Date(),
                                            sportsTeam: sportsTeam)
            
            if isEditMode {
                FM.updateData(collection: "Gatherings", document: gathering.gatheringUID, data: gathering)
                    .sink { _ in
                    } receiveValue: { [weak self] _ in
                        self?.isUploading = false
                        self?.delegate?.dismissViewController()
                    }
                    .store(in: &cancellables)
            } else {
                FM.setData(collection: "Gatherings", document: gathering.gatheringUID, data: gathering)
                    .sink { _ in
                    } receiveValue: { [weak self] _ in
                        print("Data Save")
                        self?.isUploading = false
                        self?.delegate?.dismissViewController()
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    private func loadImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        guard let url = URL(string: urlString) else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in
                return UIImage(data: data)
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
