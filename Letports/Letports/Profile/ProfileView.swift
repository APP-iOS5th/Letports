//
//  ProfileView.swift
//  Letports
//
//  Created by mosi on 8/13/24.
//
import UIKit

class ProfileView: UIView {
    
    private lazy var profileIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.backgroundColor = .lpSub
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var nickName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var simpleInfo: UILabel = {
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
        addSubview(nickName)
        addSubview(simpleInfo)
        addSubview(editProfileButton)
        
        NSLayoutConstraint.activate([
            profileIV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileIV.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileIV.widthAnchor.constraint(equalToConstant: 70),
            profileIV.heightAnchor.constraint(equalToConstant: 70),
            
            nickName.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
            nickName.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            nickName.trailingAnchor.constraint(lessThanOrEqualTo: editProfileButton.leadingAnchor, constant: -10),
            
            simpleInfo.leadingAnchor.constraint(equalTo: nickName.leadingAnchor),
            simpleInfo.topAnchor.constraint(equalTo: nickName.bottomAnchor, constant: 5),
            simpleInfo.trailingAnchor.constraint(equalTo: nickName.trailingAnchor),
            
            editProfileButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            editProfileButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            editProfileButton.widthAnchor.constraint(equalToConstant: 64),
            editProfileButton.heightAnchor.constraint(equalToConstant: 21)
        ])
    }
    
    func configure(with user: User?) {
        guard let user = user else { return }
        profileIV.loadImage(from: user.image)
        nickName.text = user.nickname
        simpleInfo.text = user.simpleInfo
    }
}
