//
//  GatheringBoardUplaodImageTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit

class GatheringBoardUplaodImageTVCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "모임 대표 사진"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) var uploadImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.backgroundColor = .lp_lightGray
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private(set) lazy var imageUploadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapUploadImage), for: .touchUpInside)
        button.tintColor = .lp_black
        button.setTitleColor(UIColor.lp_black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: GatheringBoardUploadDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .lp_background_white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = .lp_background_white
        
        [titleLabel, uploadImageView].forEach {
            contentView.addSubview($0)
        }
        
        uploadImageView.addSubview(imageUploadButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            uploadImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            uploadImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            uploadImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            uploadImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.51),
            uploadImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            imageUploadButton.topAnchor.constraint(equalTo: uploadImageView.topAnchor),
            imageUploadButton.leadingAnchor.constraint(equalTo: uploadImageView.leadingAnchor),
            imageUploadButton.trailingAnchor.constraint(equalTo: uploadImageView.trailingAnchor),
            imageUploadButton.bottomAnchor.constraint(equalTo: uploadImageView.bottomAnchor)
        ])
    }
    
    func configureCell(image: UIImage?) {
        if image != nil {
            if let selectedImage = image {
                uploadImageView.image = selectedImage
            }
        } else {
            uploadImageView.image = nil
        }
        setupButton(image: image)
    }
    
    private func setupButton(image: UIImage?) {
        imageUploadButton.setTitle(image != nil ? nil : "앨범에서 선택", for: .normal)
        imageUploadButton.setImage(image != nil ? nil : UIImage(systemName: "camera"), for: .normal)
    }
    
    
    @objc func didTapUploadImage() {
        self.delegate?.didTapUploadImage()
    }
}
