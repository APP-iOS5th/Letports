//
//  Extension+String.swift
//  Letports
//
//  Created by mosi on 9/1/24.
//

import Foundation

extension String {
    func calculateLength() -> Int {
        guard let data = self.data(using: .utf8) else { return 0 }
        
        var length = 0
        var byteCount = 0
        
        let bytes = [UInt8](data)
        var i = 0
        
        while i < bytes.count {
            let byte = bytes[i]
            
            if byte & 0x80 == 0 {
                byteCount += 1
                if byteCount % 2 == 0 {
                    length += byteCount / 2
                    byteCount = 0
                }
                i += 1
            } else {
                var charByteCount = 1
                if (byte & 0xE0) == 0xC0 {
                    charByteCount = 2
                } else if (byte & 0xF0) == 0xE0 {
                    charByteCount = 3
                } else if (byte & 0xF8) == 0xF0 {
                    charByteCount = 4
                } else {
                    charByteCount = 1
                }
                
                if charByteCount == 3 {
                    length += 1
                } else {
                    byteCount += charByteCount
                    if byteCount % 2 == 0 {
                        length += byteCount / 2
                        byteCount = 0
                    }
                }
                i += charByteCount
            }
        }
        
        if byteCount > 0 {
            length += byteCount / 2
        }
        
        return length
    }
}
