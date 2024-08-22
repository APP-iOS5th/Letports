//
//  ProfileView.swift
//  Letports
//
//  Created by mosi on 8/13/24.
//
import UIKit
import Kingfisher

class ProfileTVCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
       let view = UIView()
       view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
   }()
    
     private lazy var profileIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        label.textColor = UIColor(named: "lp_gray")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("프로필 변경", for: .normal)
        btn.backgroundColor = UIColor(named: "lp_sub")
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
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
        contentView.addSubview(containerView)
        [profileIV, nickNameLabel, simpleInfoLabel, editProfileButton].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 361),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            profileIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            profileIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            profileIV.widthAnchor.constraint(equalToConstant: 70),
            profileIV.heightAnchor.constraint(equalToConstant: 70),
            
            nickNameLabel.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
            nickNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            nickNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editProfileButton.leadingAnchor, constant: -10),
            
            simpleInfoLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 5),
            simpleInfoLabel.trailingAnchor.constraint(equalTo: nickNameLabel.trailingAnchor),
            
            editProfileButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            editProfileButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            editProfileButton.widthAnchor.constraint(equalToConstant: 64),
            editProfileButton.heightAnchor.constraint(equalToConstant: 21)
        ])
    }
    
    func setEditButtonAction(target: Any?, action: Selector) {
           editProfileButton.addTarget(target, action: action, for: .touchUpInside)
       }
    
    func configure(with user: LetportsUser) {
        nickNameLabel.text = user.nickname
        simpleInfoLabel.text = user.simpleInfo
        guard let url = URL(string: user.image) else {
            profileIV.image = UIImage(systemName: "person.circle")
                return
            }
            let placeholder = UIImage(systemName: "person.circle")
        profileIV.kf.setImage(with: url, placeholder: placeholder)
            
        }
    
   
}
