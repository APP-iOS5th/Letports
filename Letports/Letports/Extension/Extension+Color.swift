//
//  Extension+Color.swift
//  Letports
//
//  Created by Chung Wussup on 8/7/24.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(_ rgb: String, alpha: CGFloat = 1.0) {
        guard rgb.hasPrefix("#") else {
            fatalError("rgb does not start with a #.")
        }
        
        let hexString = String(rgb[rgb.index(rgb.startIndex, offsetBy: 1) ..< rgb.endIndex])
        
        guard hexString.count == 6 else {
            fatalError("hexString has an invalid length.")
        }
        
        guard let hexValue = UInt32(hexString, radix: 16) else {
            fatalError("hexString is not a hexadecimal.")
        }
        
        let red = CGFloat((hexValue & 0xFF0000) >> 16) / CGFloat(255)
        let green = CGFloat((hexValue & 0x00FF00) >> 8) / CGFloat(255)
        let blue = CGFloat(hexValue & 0x0000FF) / CGFloat(255)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Hex 값이 "#"으로 시작하는 경우 제거
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        // Hex 값은 6자리 또는 8자리여야 함 (RGB 또는 ARGB)
        if hexString.count != 6 && hexString.count != 8 {
            self.init(white: 0.0, alpha: 0.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        // RGB 또는 ARGB 값을 처리
        let red, green, blue, alpha: CGFloat
        if hexString.count == 6 {
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            alpha = 1.0
        } else {
            alpha = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            red = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x000000FF) / 255.0
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Letports Black - #2E353D
    class var lp_black: UIColor {
        return UIColor(named: "lp_black") ?? UIColor("#2E353D")
    }

    /// Letports White - #FFFFFF
    class var lp_white: UIColor {
        return UIColor(named: "lp_white") ?? UIColor("#FFFFFF")
    }
    
    /// Letports White - #FFFFFF
    class var lp_gray: UIColor {
        return UIColor(named: "lp_gray") ?? UIColor("#BBBBBB")
    }
    
    /// Letports Background White - #F4F4F4
    class var lp_background_white: UIColor {
        return UIColor(named: "lp_background_white") ?? UIColor("#F4F4F4")
    }
    
    /// Letports Main - #7BA9D3
    class var lp_main: UIColor {
        return UIColor(named: "lp_main") ?? UIColor("#7BA9D3")
    }
    
    /// Letports Tint - #FF6E6E
    class var lp_tint: UIColor {
        return UIColor(named: "lp_tint") ?? UIColor("#FF6E6E")
    }
    
    /// Letports Sub - #9ABCDC
    class var lp_sub: UIColor {
        return UIColor(named: "lp_sub") ?? UIColor("#9ABCDC")
    }
    
    /// Letports Separator - #D9D9D9
    class var lp_separator: UIColor {
        return UIColor(named: "lp_separator") ?? UIColor("#D9D9D9", alpha: 0.25)
    }
    
    /// Letports LightGray - #D9D9D9
    class var lp_lightGray: UIColor {
        return UIColor(named: "lp_lightGray") ?? UIColor("#D9D9D9")
    }
}
