//
//  UserTVCell.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//

import UIKit

class GatherUserTVCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
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
        contentView.backgroundColor = .lp_background_white
        
        [profileIV, nickNameLabel, simpleInfoLabel, ].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 70),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            profileIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            profileIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            profileIV.widthAnchor.constraint(equalToConstant: 60),
            profileIV.heightAnchor.constraint(equalToConstant: 60),
            
            nickNameLabel.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
            nickNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            simpleInfoLabel.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 5),
            simpleInfoLabel.trailingAnchor.constraint(equalTo: nickNameLabel.trailingAnchor),
        ])
    }
    
    func configure(user: LetportsUser) {
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
