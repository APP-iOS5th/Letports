//
//  CommentInput.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import Combine
import UIKit

protocol CommentInputDelegate: AnyObject {
    func addComment(comment: String)
}

class CommentInputView: UIView {
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "댓글을 입력하세요"
        tf.borderStyle = .roundedRect
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 10
        tf.backgroundColor = .lp_white
        tf.textColor = .lp_black
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var registBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("등록", for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .lp_white
        btn.setTitleColor(.lp_gray, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(registCommentDidTap), for: .touchUpInside)
        return btn
    }()
    
    private let textFieldSV: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    weak var delegate: CommentInputDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(textFieldSV)
        [textField, registBtn].forEach { textFieldSV.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            textFieldSV.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textFieldSV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textFieldSV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textFieldSV.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            registBtn.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBindings() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap { ($0.object as? UITextField)?.text }
            .map { !$0.isEmpty }
            .sink { [weak self] isValid in
                self?.updateButtonState(isEnabled: isValid)
            }
            .store(in: &cancellables)
    }
    
    @objc private func registCommentDidTap() {
        guard let text = textField.text else { return }
        textField.text = ""
        delegate?.addComment(comment: text)
    }
    
    private func updateButtonState(isEnabled: Bool) {
        registBtn.isEnabled = isEnabled
        registBtn.setTitleColor(isEnabled ? .lp_black : .lp_gray, for: .normal)
    }

}
