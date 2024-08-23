//
//  ProfileEditView.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//
import UIKit
import Combine

class ProfileEditView: UIView {
    weak var delegate: ProfileEditDelegate?
    
    private(set) lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var profileView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.layer.borderColor = UIColor.lp_black.cgColor
        view.layer.borderWidth = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var profileImageButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 50
        btn.setImage(UIImage(systemName: "person.circle"), for: .normal)
        btn.clipsToBounds = true
        btn.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        btn.contentMode = .scaleAspectFill
        btn.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    private(set) lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "lp_black")
        label.text = "닉네임"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var nickNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = " 닉네임을 입력해보세요"
        tf.textColor = UIColor(named: "lp_black")
        tf.textAlignment = .left
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 0.3
        tf.text = ""
        tf.layer.borderColor = UIColor.lp_black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private(set) lazy var simpleInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "lp_black")
        label.text = "한줄소개"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var simpleInfoTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = " 한줄소개를 입력해보세요"
        tf.textAlignment = .left
        tf.textColor = UIColor(named: "lp_black")
        tf.layer.cornerRadius = 5
        tf.layer.borderWidth = 0.3
        tf.layer.borderColor = UIColor.lp_black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        
        addSubview(containerView)
        [profileView, nickNameLabel, nickNameTextField, simpleInfoLabel, simpleInfoTextField].forEach {
            containerView.addSubview($0)
        }
        
        profileView.addSubview(profileImageButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: simpleInfoTextField.bottomAnchor, constant: 10),
            
            profileView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            profileView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            profileView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            profileView.heightAnchor.constraint(equalToConstant: 140),
            
            profileImageButton.centerXAnchor.constraint(equalTo: profileView.centerXAnchor),
            profileImageButton.centerYAnchor.constraint(equalTo: profileView.centerYAnchor),
            profileImageButton.heightAnchor.constraint(equalToConstant: 120),
            profileImageButton.widthAnchor.constraint(equalToConstant: 120),
            
            nickNameLabel.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 15),
            nickNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            
            nickNameTextField.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 10),
            nickNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            nickNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            nickNameTextField.heightAnchor.constraint(equalToConstant: 30),
            
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameTextField.bottomAnchor, constant: 20),
            simpleInfoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            
            simpleInfoTextField.topAnchor.constraint(equalTo: simpleInfoLabel.bottomAnchor, constant: 10),
            simpleInfoTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            simpleInfoTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            simpleInfoTextField.heightAnchor.constraint(equalToConstant: 30),
            
        ])
    }
    
    @objc func imageButtonTapped () {
        delegate?.didTapEditProfileImage()
        print("ProfileEditView-imageButtonTapped")
    }
    
    
}
