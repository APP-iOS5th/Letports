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
        iv.backgroundColor = .lp_lightGray
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var profileImageButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
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
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .lp_background_white
        
        [profileImageView, profileImageButton].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            profileImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 120),
            profileImageButton.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    func configure(with viewModel: ProfileEditVM) {
        viewModel.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.profileImageView.image = image
            }
            .store(in: &cancellables)
    }
    
    @objc func imageButtonTapped() {
        delegate?.didTapEditProfileImage()
    }
}
