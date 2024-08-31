//
//  UserProfileVM.swift
//  Letports
//
//  Created by mosi on 8/24/24.
//

import Foundation
import Combine
import FirebaseFirestore

enum UserProfileCellType {
    case profile
    case userGatheringHeader
    case userGatherings
}

protocol UserProfileCoordinatorDelegate: AnyObject {
    func userProfileBackBtnDidTap()
}

class UserProfileVM {
    @Published var user: LetportsUser?
    @Published var userGatherings: [Gathering] = []
    
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: UserProfileCoordinatorDelegate?
    
    private var cellType: [UserProfileCellType] {
        var cellTypes: [UserProfileCellType] = []
        cellTypes.append(.profile)
        cellTypes.append(.userGatheringHeader)
        for _ in userGatherings {
            cellTypes.append(.userGatherings)
        }
        return cellTypes
    }
    
    init(userUID: String) {
        loadUser(user: userUID)
    }
    
    func getCellTypes() -> [UserProfileCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func userProfileBackBtnDidTap() {
        delegate?.userProfileBackBtnDidTap()
    }
    
    func loadUser(user: String) {
        FM.getData(collection: "Users", document: user, type: LetportsUser.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("loadUser->finished")
                    break
                case .failure(let error):
                    print("loadUser->",error.localizedDescription)
                }
            } receiveValue: { [weak self] fetchedUser in
                self?.user = fetchedUser
//                self?.fetchUserGatherings(for: fetchedUser)
            }
            .store(in: &cancellables)
    }
    
    
//    func fetchUserGatherings(for user: LetportsUser) {
//        FM.getDocuments(collection: "Gatherings", documentIds: user.myGathering, type: Gathering.self)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    print("loadUserGathering->finished")
//                    break
//                case .failure(let error):
//                    print("loadUserGathering->",error.localizedDescription)
//                }
//            }, receiveValue: { [weak self] gatherings in
//                guard let self = self else { return }
//                
//                let myGatherings = self.filterGatherings(gatherings, for: user)
//                self.userGatherings = myGatherings
//            })
//            .store(in: &cancellables)
//    }
//    
//    private func filterGatherings(_ gatherings: [Gathering], for user: LetportsUser) -> [Gathering] {
//        var myGatherings: [Gathering] = []
//        
//        for gathering in gatherings {
//            if gathering.gatheringMembers.contains(where: { $0.userUID == user.uid && ($0.joinStatus == "가입중" || $0.joinStatus == "마스터")}) {
//                myGatherings.append(gathering)
//            }
//        }
//        
//        return myGatherings
//    }
}


