//
//  ProfileImageTVCell.swift
//  Letports
//
//  Created by mosi on 8/23/24.
//

import UIKit
import Kingfisher
import Combine

class ProfileImageTVCell: UITableViewCell {
    weak var delegate: ProfileEditDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lp_white
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var profileImageBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(imageBtnDidTap), for: .touchUpInside)
        btn.tintColor = .lp_black
        btn.setTitleColor(UIColor.lp_black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectionStyle = .none
    }
    
    private func setupUI() {
        contentView.backgroundColor = .lp_background_white
        
        [profileImageView, profileImageBtn].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            profileImageBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageBtn.widthAnchor.constraint(equalToConstant: 120),
            profileImageBtn.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    @objc func imageBtnDidTap() {
        delegate?.didTapEditProfileImage()
    }
    
    func configure(with image: UIImage?) {
        if let image = image {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
}
