//
//  SimpleInfoTVCell.swift
//  Letports
//
//  Created by mosi on 8/23/24.
//
import UIKit

class SimpleInfoTVCell: UITableViewCell {
    
    weak var delegate: ProfileEditDelegate?
    
    private lazy var simpleInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "자기소개"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var simpleInfoTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "자기소개를 입력해주세요"
        tf.textColor = .lp_black
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(simpleInfoDidChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
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
        [simpleInfoLabel, simpleInfoTextField, limitLabel, textCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            simpleInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            simpleInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            simpleInfoTextField.topAnchor.constraint(equalTo: simpleInfoLabel.bottomAnchor, constant: 10),
            simpleInfoTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            simpleInfoTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            limitLabel.topAnchor.constraint(equalTo: simpleInfoTextField.bottomAnchor, constant: 5),
            limitLabel.leadingAnchor.constraint(equalTo: simpleInfoTextField.leadingAnchor, constant: 5),
            
            textCountLabel.topAnchor.constraint(equalTo: simpleInfoTextField.bottomAnchor, constant: 5),
            textCountLabel.trailingAnchor.constraint(equalTo: simpleInfoTextField.trailingAnchor, constant: -5),
            textCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func simpleInfoDidChange() {
        if let text = simpleInfoTextField.text {
            delegate?.editUserSimpleInfo(content: text)
            if text.count == 20 {
                limitLabel.text = "자기소개는 최대 20자까지 입력할 수 있습니다."
                limitLabel.isHidden = false
            } else {
                limitLabel.isHidden = true
            }
            textCountLabel.text = "\(text.count)/20"
        }
    }
    
    func configure(with simpleInfo: String?) {
        simpleInfoTextField.text = simpleInfo ?? ""
        limitLabel.isHidden = true
        textCountLabel.text = "\(simpleInfo?.count ?? 0)/20"
    }
}

extension SimpleInfoTVCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let textLength = newText.count
        
        return textLength <= 20
    }
}
