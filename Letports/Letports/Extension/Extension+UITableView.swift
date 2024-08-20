//
//  Extension+UITableView.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import Foundation
import UIKit

extension UITableView {
    ///TableView Cell register
    ///Identifier를 따로 설정하지 않고 Cell Class Name을 통해 identifier 등록
    func register(cellClass: AnyClass) {
        let className = String(describing: cellClass)
        self.register(cellClass, forCellReuseIdentifier: className)
    }
    
    
    ///TableView Cell을 여러가지 register해야할 때 사용
    ///
    /// **[사용 방법]**
    ///
    ///여러개의 Cell을 하나의 TableView에 등록해야할 때 사용할 수 있음.
    ///
    ///cellClasses Parameter에 넣어야할 Cell을  CellName.Self의 형태로 넣어줄 수 있음
    /// ```swift
    ///tableView.registersCell(cellClasses: AnyCell.Self,
    ///                                     CustomCell.Self)
    ///```
    ///위와 같은 형태로 사용 가능.
    ///
    ///Cell은 제한 없이 넣을 수 있음.
    func registersCell(cellClasses: AnyClass...) {
        cellClasses.forEach { cellClass in
            self.register(cellClass: cellClass)
        }
    }
    
    
    ///TableView Cell을 dequeueReusableCell를 할때 사용
    ///
    ///**[사용방법]**
    ///
    ///```swift
    ///tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) {
    ///     if let cell: GatheringBoardUploadMainTVCell = tableView.loadCell(indexPath: indexPath) {
    ///         return cell
    ///     }
    ///}
    ///```
    ///
    ///위와 같이 사용할 수 있음
    ///조금 더 줄여서 쓸 수 있게 만들기 위함
    func loadCell<T>(indexPath: IndexPath) -> T? {
        return self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T
    }
}
