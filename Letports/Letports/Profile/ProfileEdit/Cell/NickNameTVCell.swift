//
//  NickNameTVCell.swift
//  Letports
//
//  Created by mosi on 8/23/24.
//

import UIKit

class NickNameTVCell: UITableViewCell {
    
    weak var delegate: ProfileEditDelegate?
    var moveToNextTextField: (() -> Void)?
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 20)
        label.text = "닉네임"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var nickNameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "닉네임을 입력해주세요"
        tf.textColor = .lp_black
        tf.backgroundColor = .lp_white
        tf.borderStyle = .roundedRect
		tf.font = .lp_Font(.regular, size: 12)
        tf.delegate = self
        tf.addTarget(self, action: #selector(nickNameDidChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    } ()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 12)
        label.textColor = .lp_tint
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 12)
        label.textColor = .lp_gray
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
    
    @objc private func nickNameDidChange() {
        guard let text = nickNameTextField.text else { return  }
        let byteLength = text.calculateLength()
        
        delegate?.editUserNickName(content: nickNameTextField.text ?? "")
        
        if byteLength == 8 {
            limitLabel.text = "닉네임은 한글 최대 8자, 영문 및 숫자 최대 16자까지 가능합니다."
            limitLabel.isHidden = false
        } else {
            limitLabel.isHidden = true
        }
        
        textCountLabel.text = "\(byteLength)/8"
    }
    
    func configure(with nickName: String?) {
        nickNameTextField.text = nickName ?? ""
        limitLabel.isHidden = true
        let text = nickName
        guard let length = text?.calculateLength() else { return }
        textCountLabel.text = "\(length)/8"
    }
}

extension NickNameTVCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        moveToNextTextField?()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let byteLength = newText.calculateLength()
        
        return byteLength <= 8
    }
}
