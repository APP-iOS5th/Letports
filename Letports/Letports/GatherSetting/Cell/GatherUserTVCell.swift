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
       iv.layer.cornerRadius = 12
       iv.clipsToBounds = true
       iv.contentMode = .scaleAspectFill
       iv.translatesAutoresizingMaskIntoConstraints = false
       return iv
   }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
        self.backgroundColor = .lp_background_white
        contentView.addSubview(containerView)
        [profileIV, nickNameLabel, simpleInfoLabel, ].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 361),
            containerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            profileIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            profileIV.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileIV.widthAnchor.constraint(equalToConstant: 44),
            profileIV.heightAnchor.constraint(equalToConstant: 44),
            
            nickNameLabel.topAnchor.constraint(equalTo: profileIV.topAnchor),
            nickNameLabel.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
         
           
            
            simpleInfoLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 5),
            simpleInfoLabel.trailingAnchor.constraint(equalTo: nickNameLabel.trailingAnchor),
            
        ])
    }
    
    func configure(with user: GatheringMember) {
        nickNameLabel.text = user.nickName
        simpleInfoLabel.text = user.simpleInfo
        guard let url = URL(string: user.image) else {
            profileIV.image = UIImage(systemName: "person.circle")
                return
            }
            let placeholder = UIImage(systemName: "person.circle")
        profileIV.kf.setImage(with: url, placeholder: placeholder)
            
        }
}
