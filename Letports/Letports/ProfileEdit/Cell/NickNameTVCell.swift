//
//  NickNameTVCell.swift
//  Letports
//
//  Created by mosi on 8/23/24.
//

import UIKit


class NickNameTVCell: UITableViewCell {
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "닉네임"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nickNameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "닉네임을 입력해주세요"
        tf.textColor = .lp_black
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    } ()
    
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
        [nickNameLabel, nickNameTextField].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            nickNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            nickNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nickNameTextField.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 10),
            nickNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nickNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    func configure(with nickName: String) {
        nickNameTextField.text = nickName
    }
}

