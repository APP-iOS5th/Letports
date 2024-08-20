//
//  BoardEditorContentCVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/17/24.
//

import UIKit
import KoTextCountLimit

class BoardEditorContentCVCell: UICollectionViewCell {
    private let koTextLimit = KoTextCountLimit()
    private let mainView: UIView = {
       let view = UIView()
        view.backgroundColor = .lp_white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16, weight: .regular)
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
        
    private let textCountLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lp_gray
        label.text = "0/1000"
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        [mainView ].forEach {
            contentView.addSubview($0)
        }
        
        [contentTextView, textCountLabel].forEach {
            mainView.addSubview($0)
        }
        
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainView.heightAnchor.constraint(equalToConstant: 236),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            contentTextView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20),
            textCountLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -5),
            textCountLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -5)
            
        ])
    }
    
    func configureCell(content: String?) {
        guard let content = content else { return }
        contentTextView.text = content
    }
}

extension BoardEditorContentCVCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(textView.text.count)/1000"
        delegate?.writeContent(content: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return koTextLimit.shouldChangeText(for: textView, in: range, replacementText: text, maxCharacterLimit: 1000)
    }
}
