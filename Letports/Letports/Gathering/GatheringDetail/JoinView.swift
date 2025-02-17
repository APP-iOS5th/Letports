//
//  JoinView.swift
//  Letports
//
//  Created by Yachae on 8/23/24.
//

import UIKit

protocol JoinViewDelegate: AnyObject {
    func joinViewDidTapCancel(_ joinView: JoinView)
    func joinViewDidTapJoin(_ joinView: JoinView, answer: String)
}

class JoinView: UIView {
    weak var delegate: JoinViewDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .lp_background_white
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.lp_Font(.regular, size: 20)
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plzAnswerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.lp_Font(.regular, size: 14)
        label.textColor = .lp_black
        label.text = "가입질문에 답해주세요"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var questionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .lp_Font(.regular, size: 12)
        textView.backgroundColor = .lp_background_white
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    private lazy var answerTextView: UITextView = {
        let textView = UITextView()
        textView.font = .lp_Font(.regular, size: 14)
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 20
        textView.backgroundColor = .lp_white
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "답변을 입력해주세요"
        label.font = .lp_Font(.regular, size: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("취소하기", for: .normal)
        btn.backgroundColor = UIColor(named: "lp_tint")
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.lp_Font(.regular, size: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var deleteUserButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("가입하기", for: .normal)
        btn.backgroundColor = UIColor(named: "lp_main")
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.lp_Font(.regular, size: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var containerViewCenterYConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
        answerTextView.delegate = self
        registerKeyboardNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerKeyboardNotifications()
    }
    
    // MARK: - setupUI
    
    private func setupUI() {
        self.addSubview(containerView)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, plzAnswerLabel, questionTextView, answerTextView, cancelButton, deleteUserButton].forEach {
            containerView.addSubview($0)
        }
        answerTextView.addSubview(placeholderLabel)
        
        containerViewCenterYConstraint = containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerViewCenterYConstraint!,
            containerView.widthAnchor.constraint(equalToConstant: 361),
            containerView.heightAnchor.constraint(equalToConstant: 468),
            
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            plzAnswerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            plzAnswerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            questionTextView.topAnchor.constraint(equalTo: plzAnswerLabel.bottomAnchor, constant: 5),
            questionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            questionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            questionTextView.heightAnchor.constraint(equalToConstant: 72),
            
            answerTextView.topAnchor.constraint(equalTo: questionTextView.bottomAnchor, constant: 10),
            answerTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            answerTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            answerTextView.heightAnchor.constraint(equalToConstant: 252),
            
            cancelButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 162),
            cancelButton.heightAnchor.constraint(equalToConstant: 30),
            
            deleteUserButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 16),
            deleteUserButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            deleteUserButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            deleteUserButton.widthAnchor.constraint(equalToConstant: 162),
            deleteUserButton.heightAnchor.constraint(equalToConstant: 30),
            
            placeholderLabel.topAnchor.constraint(equalTo: answerTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: answerTextView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: answerTextView.trailingAnchor, constant: -16)
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTap), for: .touchUpInside)
        deleteUserButton.addTarget(self, action: #selector(joinButtonTap), for: .touchUpInside)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - @objc
    
    @objc private func handleTap() {
        self.endEditing(true)
    }
    
    @objc private func cancelButtonTap() {
        delegate?.joinViewDidTapCancel(self)
    }
    
    @objc private func joinButtonTap() {
        let answer = answerTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if answer.isEmpty {
            showAlert(message: "가입질문에 답해주세요")
        } else {
            delegate?.joinViewDidTapJoin(self, answer: answer)
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            containerViewCenterYConstraint?.constant = -keyboardHeight / 2
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        containerViewCenterYConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showAlert(message: String) {
        guard let viewController = self.findViewController() else { return }
        
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    func configure(with gathering: Gathering) {
        titleLabel.text = gathering.gatherName
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attributedText = NSAttributedString(
            string: gathering.gatherQuestion ?? "",
            attributes: [
                .font: UIFont.lp_Font(.regular, size: 12),
                .foregroundColor: UIColor.lp_black,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        questionTextView.attributedText = attributedText
        placeholderLabel.isHidden = !answerTextView.text.isEmpty
    }
    
}

// MARK: - UITextViewDelegate
extension JoinView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        applyAttributesToTextView(textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        applyAttributesToTextView(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func applyAttributesToTextView(_ textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.lp_Font(.regular, size: 14),
            .foregroundColor: UIColor.lp_black,
            .paragraphStyle: paragraphStyle
        ]
        
        textView.typingAttributes = attributes
        
        let attributedString = NSAttributedString(string: textView.text ?? "", attributes: attributes)
        textView.attributedText = attributedString
    }
}



