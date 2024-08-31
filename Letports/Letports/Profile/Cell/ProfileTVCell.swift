//
//  ProfileView.swift
//  Letports
//
//  Created by mosi on 8/13/24.
//
import UIKit
import Kingfisher

class ProfileTVCell: UITableViewCell {
    
    weak var delegate: ProfileDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var simpleInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editProfileBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("프로필 변경", for: .normal)
        btn.backgroundColor = UIColor(named: "lp_sub")
        btn.layer.cornerRadius = 8
        btn.isHidden = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(editBtnDidTap), for: .touchUpInside)
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
        contentView.addSubview(containerView)
        contentView.backgroundColor = .lp_background_white
        
        [profileIV, nickNameLabel, simpleInfoLabel, editProfileBtn, activityIndicator].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            profileIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            profileIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            profileIV.widthAnchor.constraint(equalToConstant: 80),
            profileIV.heightAnchor.constraint(equalToConstant: 80),
            
            activityIndicator.centerXAnchor.constraint(equalTo: profileIV.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: profileIV.centerYAnchor),
            
            nickNameLabel.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
            nickNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            nickNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editProfileBtn.leadingAnchor, constant: -10),
            
            simpleInfoLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 10),
            simpleInfoLabel.trailingAnchor.constraint(equalTo: nickNameLabel.trailingAnchor),
            
            editProfileBtn.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            editProfileBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            editProfileBtn.widthAnchor.constraint(equalToConstant: 64),
            editProfileBtn.heightAnchor.constraint(equalToConstant: 21)
        ])
    }
    
    @objc func editBtnDidTap () {
        delegate?.EditProfileBtnDidTap()
    }
    
    func configure(user: LetportsUser) {
        nickNameLabel.text = user.nickname
        simpleInfoLabel.text = user.simpleInfo
        
        guard let url = URL(string: user.image) else {
            profileIV.image = UIImage(systemName: "person.circle")
            return
        }
        
        profileIV.image = nil
        activityIndicator.startAnimating()
        let placeholder = UIImage()
        
        profileIV.kf.setImage(with: url, placeholder: placeholder, options: [
            .transition(.fade(0.2)),
            .cacheOriginalImage
        ]) { result in
            self.activityIndicator.stopAnimating()
        }
    }
}
