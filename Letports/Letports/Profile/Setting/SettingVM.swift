//
//  SettingVM.swift
//  Letports
//
//  Created by mosi on 9/3/24.
//

import Foundation

enum SettingCellType {
    case notification
    case AppTermsofService
    case openLibrary
    case appInfo
    case logout
}

class SettingVM {
    
    private var cellType: [SettingCellType] {
        var cellTypes: [SettingCellType] = []
        cellTypes.append(.notification)
        cellTypes.append(.AppTermsofService)
        cellTypes.append(.openLibrary)
        cellTypes.append(.appInfo)
        cellTypes.append(.logout)
        return cellTypes
    }
    
    weak var delegate: SettingCoordinatorDelegate?
    
    func getCellTypes() -> [SettingCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func backToProfile() {
        delegate?.backToProfile()
    }
    
    func notificationUpdate() {
        print("바뀜")
    }
    
    func buttonAction(cellType: SettingCellType) {
        switch cellType {
        case .AppTermsofService:
            delegate?.appTermsofServiceDidTap()
        case .openLibrary:
            delegate?.openLibraryDidTap()
        case .appInfo:
            delegate?.appInfoDidTap()
        case .logout:
            delegate?.logoutDidTap()
        default:
            break
        }
    }
}

