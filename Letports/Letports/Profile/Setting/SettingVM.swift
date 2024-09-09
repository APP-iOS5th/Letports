//
//  SettingVM.swift
//  Letports
//
//  Created by mosi on 9/3/24.
//

import Foundation

enum SettingCellType {
    case notification
    case appTermsofService
    case personnalInfo
    case openLibrary
    case appInfo
    case logout
    case exit
}

class SettingVM {
    
    private var cellType: [SettingCellType] {
        var cellTypes: [SettingCellType] = []
        cellTypes.append(.notification)
        cellTypes.append(.appTermsofService)
        cellTypes.append(.personnalInfo)
        cellTypes.append(.openLibrary)
        cellTypes.append(.appInfo)
        cellTypes.append(.logout)
        cellTypes.append(.exit)
        return cellTypes
    }
    
    private let sections: [[SettingCellType]] = [
        [.notification ],
        [.appTermsofService, .personnalInfo, .openLibrary, .appInfo],
        [.logout, .exit]
        ]
    
    weak var delegate: SettingCoordinatorDelegate?
    var notificationToggleState: Bool = false
    
    func getCellTypes() -> [SettingCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    func getSectionCount() -> Int {
        return sections.count
    }
    
    func getRowCount(for section: Int) -> Int {
        return sections[section].count
    }
    
    func getCellType(for indexPath: IndexPath) -> SettingCellType {
          return sections[indexPath.section][indexPath.row]
      }
    
    func getSectionTitle(for section: Int) -> String? {
            switch section {
            case 0:
                return "설정"
            case 1:
                return "앱 정보"
            case 2:
                return "유저"
            default:
                return nil
            }
        }
    
    func backToProfile() {
        delegate?.backToProfile()
    }
    
    func exit() {
        
    }
    
    func logout() {
        delegate?.logoutDidTap()
    }
    
    func buttonAction(cellType: SettingCellType) {
        switch cellType {
        case .appTermsofService:
            delegate?.presentBottomSheet(with: URL(string:"https://candied-flood-c4c.notion.site/986a0cfb61584890a4bd512a87ac268a?pvs=4")!)
        case .personnalInfo:
            delegate?.presentBottomSheet(with: URL(string:"https://candied-flood-c4c.notion.site/a55bf0b1971d43658ac4a2d626524f10?pvs=4")!)
        case .openLibrary:
            delegate?.openLibraryDidTap()
        case .logout:
            break
        case .exit:
            break
        default:
            break
        }
    }
}

