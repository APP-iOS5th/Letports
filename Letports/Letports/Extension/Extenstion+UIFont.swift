//
//  Extenstion+UIFont.swift
//  Letports
//
//  Created by Yachae on 9/5/24.
//

import UIKit

extension UIFont {
	enum GmarketSan: String {
		case regular = "GmarketSansMedium"
		case bold = "GmarketSansBold"
		case light = "GmarketSansLight"
	}
	
	static func lp_Font(_ font: GmarketSan, size: CGFloat) -> UIFont {
		guard let customFont = UIFont(name: font.rawValue, size: size) else {
			return UIFont.systemFont(ofSize: size)
		}
		return customFont
	}
}

/*
아래처럼 사용
label.font = .custom(.regular, size: 16)
button.titleLabel?.font = .custom(.bold, size: 18)
*/

