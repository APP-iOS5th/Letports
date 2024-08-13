//
//  Extension+UIImage.swift
//  Letports
//
//  Created by Chung Wussup on 8/6/24.
//

import UIKit

extension UIImage {
    func resized(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
