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
        
    
}
