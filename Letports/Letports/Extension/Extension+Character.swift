//
//  Extension+Character.swift
//  Letports
//
//  Created by mosi on 9/1/24.
//

extension Character {
    var isHangul: Bool {
        return ("\u{AC00}" <= self && self <= "\u{D7AF}") ||
               ("\u{1100}" <= self && self <= "\u{11FF}") ||
               ("\u{3130}" <= self && self <= "\u{318F}")
    }
}
