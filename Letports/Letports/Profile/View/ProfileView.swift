//
//  ProfileView.swift
//  Letports
//
//  Created by mosi on 8/13/24.
//
import UIKit

class ProfileView: UIView {
    
     lazy var profileIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
     lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     lazy var simpleInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "lp_gray")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     lazy var editProfileButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("프로필 변경", for: .normal)
        btn.backgroundColor = UIColor(named: "lp_sub")
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(profileIV)
        addSubview(nickNameLabel)
        addSubview(simpleInfoLabel)
        addSubview(editProfileButton)
        
        NSLayoutConstraint.activate([
            profileIV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileIV.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileIV.widthAnchor.constraint(equalToConstant: 70),
            profileIV.heightAnchor.constraint(equalToConstant: 70),
            
            nickNameLabel.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
            nickNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            nickNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editProfileButton.leadingAnchor, constant: -10),
            
            simpleInfoLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 5),
            simpleInfoLabel.trailingAnchor.constraint(equalTo: nickNameLabel.trailingAnchor),
            
            editProfileButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            editProfileButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            editProfileButton.widthAnchor.constraint(equalToConstant: 64),
            editProfileButton.heightAnchor.constraint(equalToConstant: 21)
        ])
    }
    
    func setEditButtonAction(target: Any?, action: Selector) {
           editProfileButton.addTarget(target, action: action, for: .touchUpInside)
       }
    
   
}
