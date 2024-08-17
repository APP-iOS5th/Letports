//
//  BoarderEditorPhotoCVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/14/24.
//

import UIKit

class BoarderEditorPhotoCVCell: UICollectionViewCell {
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.backgroundColor = .lp_lightGray
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var photoAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .lp_white
        button.addTarget(self, action: #selector(didTapAddPhotoButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .lp_black
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.backgroundColor = .lp_gray
        button.addTarget(self, action: #selector(didTapDeletePhotoButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: BoarderEditorPhotoCVCellDelegate?
    
    private var photoIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
    }
    
    private func setupUI() {
        [photoImageView, photoAddButton, cancelButton].forEach {
            contentView.addSubview($0)
        }
        
        [photoAddButton].forEach {
            photoImageView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoAddButton.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            photoAddButton.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            photoAddButton.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
            photoAddButton.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            cancelButton.widthAnchor.constraint(equalToConstant: 36),
            cancelButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func photoCellSetup(isPhoto: Bool, photo: UIImage? = nil, photoIndex: Int = 0) {
        photoAddButton.isHidden = isPhoto
        cancelButton.isHidden = !isPhoto
        
        if isPhoto {
            photoImageView.image = photo
            self.photoIndex = photoIndex
        }
    }
    
    @objc func didTapAddPhotoButton() {
        delegate?.didTapAddPhotoButton()
    }
    
    @objc func didTapDeletePhotoButton() {
        delegate?.didTapDeletePhotoButton(photoIndex: self.photoIndex)
    }
}
