//
//  BoarderEditorPhotoCVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/14/24.
//

import UIKit

class BoarderEditorPhotoCVCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lp_lightGray
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let photoAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .lp_white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .lp_black
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.backgroundColor = .lp_gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [imageView, photoAddButton, cancelButton].forEach {
            contentView.addSubview($0)
        }
        
        [photoAddButton].forEach {
            imageView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoAddButton.topAnchor.constraint(equalTo: imageView.topAnchor),
            photoAddButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            photoAddButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            photoAddButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            cancelButton.widthAnchor.constraint(equalToConstant: 36),
            cancelButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func photoCellSetup(isPhoto: Bool) {
        photoAddButton.isHidden = isPhoto
        cancelButton.isHidden = !isPhoto
        
    }
}
