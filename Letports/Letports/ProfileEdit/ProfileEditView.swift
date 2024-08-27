//
//  ProfileEditView.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//
import UIKit
import Combine

class ProfileEditView: UIView {
    
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "lp_black")
        label.text = "닉네임"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     lazy var nickNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = " 닉네임을 입력해보세요"
        tf.textColor = UIColor(named: "lp_black")
        tf.textAlignment = .left
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 0.3
        tf.text = ""
        tf.layer.borderColor = UIColor.lp_black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
     lazy var simpleInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "lp_black")
        label.text = "한줄소개"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var simpleInfoTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = " 한줄소개를 입력해보세요"
        tf.textAlignment = .left
        tf.textColor = UIColor(named: "lp_black")
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 0.3
        tf.layer.borderColor = UIColor.lp_black.cgColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
        
    lazy var profileImageButton: UIButton = {
            let button = UIButton(type: .system)
            button.imageView?.contentMode = .scaleAspectFill
            button.layer.cornerRadius = 50
            button.clipsToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
    lazy var progressView: UIProgressView = {
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.isHidden = true  // 초기에는 숨김
            return progressView
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
        addSubview(profileImageButton)
        addSubview(progressView)
        addSubview(nickNameLabel)
        addSubview(nickNameTextField)
        addSubview(simpleInfoLabel)
        addSubview(simpleInfoTextField)
        
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            profileImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 120),
            profileImageButton.heightAnchor.constraint(equalToConstant: 120),
            
            progressView.centerXAnchor.constraint(equalTo: profileImageButton.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor),
            progressView.widthAnchor.constraint(equalTo: profileImageButton.widthAnchor),
            
            nickNameLabel.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 20),
            nickNameLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nickNameTextField.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 10),
            nickNameTextField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nickNameTextField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nickNameTextField.heightAnchor.constraint(equalToConstant: 30),
            
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameTextField.bottomAnchor, constant: 30),
            simpleInfoLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            simpleInfoTextField.topAnchor.constraint(equalTo: simpleInfoLabel.bottomAnchor, constant: 10),
            simpleInfoTextField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            simpleInfoTextField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            simpleInfoTextField.heightAnchor.constraint(equalToConstant: 30),
           
        ])
    }

    
    
    
}
