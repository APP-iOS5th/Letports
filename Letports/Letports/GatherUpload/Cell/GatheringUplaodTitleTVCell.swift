//
//  GatheringBoardUplaodTitleTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit
import KoTextCountLimit

class GatheringUplaodTitleTVCell: UITableViewCell {
    
    private let koTextLimit = KoTextCountLimit()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 18)
        label.text = "소모임명"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "모임명을 입력하세요"
        tf.backgroundColor = .lp_white
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lp_gray.cgColor
        tf.layer.cornerRadius = 10
        tf.delegate = self
        tf.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: 0.0))
        tf.leftViewMode = .always
		tf.font = .lp_Font(.light, size: 12)
        tf.textColor = .lp_black
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/100"
        label.textColor = .lp_gray
		label.font = .lp_Font(.regular, size: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    weak var delegate: GatheringUploadDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .lp_background_white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        [titleLabel, titleTextField, textCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 36),
            
            textCountLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            textCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            textCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    
    func configureCell(title: String?) {
        guard let title = title else { return }
        self.textCountCheck(text: title)
        self.titleTextField.text = title
        
    }
 
    @objc func textFieldDidChange() {
        if let text = titleTextField.text {
            self.textCountCheck(text: text)
            self.delegate?.sendGatherName(content: text)
        }
    }
    
    private func textCountCheck(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.textCountLabel.text = "\(text.count)/20"
        }
    }
    
}

extension GatheringUplaodTitleTVCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return koTextLimit.shouldChangeText(for: textField, in: range, 
                                            replacementText: string, maxCharacterLimit: 20)
    }
}
