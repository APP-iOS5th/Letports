//
//  LoadingIndicatorView.swift
//  Letports
//
//  Created by Chung Wussup on 8/19/24.
//

import UIKit

class LoadingIndicatorView: UIView {

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        self.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func startAnimating() {
        self.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.isHidden = true
        activityIndicator.stopAnimating()
    }
}
