//
//  SplashVC.swift
//  Letports
//
//  Created by John Yun on 9/2/24.
//

import UIKit
import AVFoundation

class SplashVC: UIViewController {
    
    private var logoImageView: UIImageView!
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogo()
    }
    
    private func setupView() {
        view.backgroundColor = .lpWhite
        
        logoImageView = UIImageView(image: UIImage(named: "launch"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        
    }
    
    private func animateLogo() {
        UIView.animate(withDuration: 1.0, animations: {
            self.logoImageView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.completion?()
            }
        }
    }
    
    
}
