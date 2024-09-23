//
//  BoardEditorTitleCVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/17/24.
//

import Foundation
import UIKit

class BoardEditorHeaderCVCell: UICollectionReusableView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 18)
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.configureText(text: nil, photoCount: nil)
    }
    
    func configureText(text: String?, photoCount: Int? = nil) {
        
        let fullText = NSMutableAttributedString()
        
        if let text = text {
            let textAttributedString = NSAttributedString(string: "\(text)", attributes: [
				.font: UIFont.lp_Font(.regular, size: 18),
                .foregroundColor: UIColor.lp_black
            ])
            fullText.append(textAttributedString)
        }
        
        if let photoCount = photoCount {
            let photoCountString = NSAttributedString(string: " \(photoCount)/5", attributes: [
                .font: UIFont.lp_Font(.regular, size: 12),
                .foregroundColor: UIColor.lightGray
            ])
            fullText.append(photoCountString)
        }
        
        self.titleLabel.attributedText = fullText
    }
    
}
