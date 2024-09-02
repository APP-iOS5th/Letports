//
//  GatheringUploadVM.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import Foundation
import UIKit
import Combine
import FirebaseCore

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
    
    @Published private(set) var selectedImage: UIImage?
    @Published private(set) var addButtonEnable: Bool = true
    @Published private(set) var gatherInfoText: String?
    @Published private(set) var gatherQuestionText: String?
    @Published private(set) var gatherNameText: String?
    @Published private(set) var isUploading: Bool = false
    
    private(set) var isEditMode: Bool
    private var gatehringID: String?
    private var boardId: String?
    
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
    
    
    init(gathering: Gathering? = nil) {
        if let gathering = gathering {
            self.isEditMode = true
            self.gatehringID = gathering.gatheringUid
            self.gatherInfoText = gathering.gatherInfo
            self.gatherQuestionText = gathering.gatherQuestion
            self.memMaxCount = gathering.gatherMaxMember
            self.gatherNameText = gathering.gatherName
            
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
            
            let uuid = self.gatehringID == nil ? UUID().uuidString : self.gatehringID!
            
            
            
            let gathering = Gathering(gatherImage: imageUrl,
                                      gatherInfo: gatherInfo,
                                      gatherMaxMember: memMaxCount,
                                      gatherName: gatherName,
                                      gatherNowMember: 1,
                                      gatherQuestion: gatherQuestion,
                                      gatheringCreateDate: Timestamp(date: Date()),
                                      gatheringMaster: UserManager.shared.getUserUid(),
                                      gatheringSports: UserManager.shared.getUser().userSports,
                                      gatheringSportsTeam: UserManager.shared.getUser().userSportsTeam,
                                      gatheringUid: uuid)
            
            if isEditMode {
                let collectionPath: [FirestorePathComponent] = [
                    .collection(.gatherings),
                    .document(uuid)
                ]
                
                FM.updateData(pathComponents: collectionPath, model: gathering)
                    .sink { _ in
                    } receiveValue: { [weak self] _ in
                        self?.isUploading = false
                        self?.delegate?.dismissViewController()
                    }
                    .store(in: &cancellables)
            } else {
                let collectionPath: [FirestorePathComponent] = [
                    .collection(.gatherings),
                    .document(uuid)
                ]
                
                let userCollectionPath: [FirestorePathComponent] = [
                    .collection(.user),
                    .document(UserManager.shared.getUserUid()),
                    .collection(.myGathering),
                    .document(uuid)
                ]
                
                let masterCollectionPath: [FirestorePathComponent] = [
                    .collection(.gatherings),
                    .document(uuid),
                    .collection(.gatheringMembers),
                    .document(UserManager.shared.getUserUid())
                ]
                
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: currentDate)
                
                let gatheringData = MyGatherings(uid: uuid)
                let masterData = GatheringMember(answer: "Master", joinDate: dateString, joinStatus: "joined", userUID: UserManager.shared.getUserUid())
                
                FM.setData(pathComponents: collectionPath, data: gathering)
                    .map { _ in
                        // 첫 번째 작업이 완료된 후 두 번째 작업을 시작합니다.
                        FM.setData(pathComponents: userCollectionPath, data: gatheringData)
                    }
                    .flatMap { secondTask in
                        // 두 번째 작업이 완료된 후 세 번째 작업을 시작합니다.
                        secondTask.map { _ in
                            FM.setData(pathComponents: masterCollectionPath, data: masterData)
                        }
                    }
                    .switchToLatest()
                    .sink { completion in
                        switch completion {
                        case .finished:
                            print("All tasks finished")
                        case .failure(let error):
                            print("An error occurred: \(error)")
                        }
                    } receiveValue: { [weak self] _ in
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
