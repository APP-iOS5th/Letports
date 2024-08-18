//
//  BoardEditorTitleCVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/17/24.
//

import UIKit
import KoTextCountLimit

class BoardEditorTitleCVCell: UICollectionViewCell {
    private let koTextLimit = KoTextCountLimit()
    
    private lazy var titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "제목을 입력하세요"
        tf.backgroundColor = .lp_white
        tf.layer.cornerRadius = 10
        tf.delegate = self
        tf.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: 0.0))
        tf.leftViewMode = .always
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    weak var delegate: BoardEditorDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lp_background_white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [titleTextField].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 34),
            titleTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc func textFieldDidChange() {
        if let text = titleTextField.text {
            self.delegate?.writeTitle(content: text)
        }
    }
}

extension BoardEditorTitleCVCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        return koTextLimit.shouldChangeText(for: textField, in: range, replacementText: string, maxCharacterLimit: 10)
    }
}
