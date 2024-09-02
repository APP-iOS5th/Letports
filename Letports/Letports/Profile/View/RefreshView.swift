//
//  RefreshView.swift
//  Letports
//
//  Created by mosi on 9/1/24.
//

import UIKit

class RefreshView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .lp_white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor.lp_gray.withAlphaComponent(0.7)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    func setMessage(_ message: String) {
        messageLabel.text = message
    }
}
