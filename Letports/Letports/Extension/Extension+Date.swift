//
//  Extension+Date.swift
//  Letports
//
//  Created by Chung Wussup on 8/30/24.
//

import Foundation

extension Date {
    func toString(format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
