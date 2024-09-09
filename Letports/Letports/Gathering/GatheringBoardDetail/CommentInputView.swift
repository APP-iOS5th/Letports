//
//  CommentInput.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

protocol CommentInputDelegate: AnyObject {
    func didTapAddComment(comment: String)
}

class CommentInputView: UIView {
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "댓글을 입력하세요"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 10
        tf.backgroundColor = .lp_white
        tf.textColor = .lp_black
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()
    
    private lazy var registBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("등록", for: .normal)
        btn.setTitleColor(.lp_gray, for: .normal)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .lp_white
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(didTapRegistButton), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var textFieldStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [textField, registBtn])
        sv.axis = .horizontal
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    weak var delegate: CommentInputDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(textFieldStackView)
        
        NSLayoutConstraint.activate([
            textFieldStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textFieldStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            registBtn.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func didTapRegistButton() {
        guard let comment = textField.text else { return }
        delegate?.didTapAddComment(comment: comment)
        textField.resignFirstResponder()
    }
    
    private func updateButtonState(isEnabled: Bool) {
        registBtn.isEnabled = isEnabled
        registBtn.setTitleColor(isEnabled ? .lp_black : .lp_gray, for: .normal)
    }
    
    func clearText() {
        textField.text = ""
        updateButtonState(isEnabled: false)
    }
}

// MARK: - UITextFieldDelegate
extension CommentInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, 
                   replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        updateButtonState(isEnabled: !updatedText.isEmpty)
        return true
    }
}
