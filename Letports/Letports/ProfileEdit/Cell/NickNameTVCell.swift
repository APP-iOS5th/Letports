//
//  NickNameTVCell.swift
//  Letports
//
//  Created by mosi on 8/23/24.
//

import UIKit


class NickNameTVCell: UITableViewCell {
    
    weak var delegate: ProfileEditDelegate?
    
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
        tf.addTarget(self, action: #selector(nickNameDidChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    } ()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
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
    }
    
    private func setupUI() {
        contentView.backgroundColor = .lp_background_white
        [nickNameLabel, nickNameTextField, limitLabel, textCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            nickNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nickNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nickNameTextField.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 10),
            nickNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nickNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            limitLabel.topAnchor.constraint(equalTo: nickNameTextField.bottomAnchor, constant: 5),
            limitLabel.leadingAnchor.constraint(equalTo: nickNameTextField.leadingAnchor, constant: 5),
            
            textCountLabel.topAnchor.constraint(equalTo: nickNameTextField.bottomAnchor, constant: 5),
            textCountLabel.trailingAnchor.constraint(equalTo: nickNameTextField.trailingAnchor, constant: -5),
            textCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func nickNameDidChange() {
        guard let text = nickNameTextField.text else { return }
        
        let length = text.calculateLength()
        
        delegate?.editUserNickName(content: text)
        
        if length > 16 {
            limitLabel.text = "한글8자, 영문16자 이하로 입력해주세요."
            limitLabel.isHidden = false
        } else {
            limitLabel.isHidden = true
        }
        
        textCountLabel.text = "\(length)/16"
    }
    
    func configure(with nickName: String?) {
        nickNameTextField.text = nickName ?? ""
        limitLabel.isHidden = true
        let text = nickName
        guard let length = text?.calculateLength() else { return }
        textCountLabel.text = "\(length)/16"
    }
}

