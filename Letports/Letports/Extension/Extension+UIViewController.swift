//
//  Extension+UIViewController.swift
//  Letports
//
//  Created by mosi on 9/7/24.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, confirmTitle: String, cancelTitle: String? = nil, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
    
        let confirmAction = UIAlertAction(title: confirmTitle, style: .destructive) { _ in onConfirm() }
        alert.addAction(confirmAction)
        
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
            alert.addAction(cancelAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
}
