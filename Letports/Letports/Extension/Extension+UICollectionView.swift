//
//  Extension+UICollectionView.swift
//  Letports
//
//  Created by Chung Wussup on 8/14/24.
//

import Foundation
import UIKit


extension UICollectionView {
    func register(cellClass: AnyClass) {
        let className = String(describing: cellClass)
        self.register(cellClass, forCellWithReuseIdentifier: className)
    }
    
    func resgistersCell(cellClasses: AnyClass...) {
        cellClasses.forEach { cellClass in
            self.register(cellClass: cellClass)
        }
    }

    func loadCell<T>(indexPath: IndexPath) -> T? {
        return self.dequeueReusableCell(withReuseIdentifier: String(describing: T.self),for: indexPath) as? T
    }
}
