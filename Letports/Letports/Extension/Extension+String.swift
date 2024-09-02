//
//  Extension+String.swift
//  Letports
//
//  Created by mosi on 9/1/24.
//

import Foundation

extension String {
    func calculateLength() -> Int {
        var length = 0
        for char in self {
            if char.isHangul {
                length += 2
            } else {
                length += 1 
            }
        }
        return length
    }
}
