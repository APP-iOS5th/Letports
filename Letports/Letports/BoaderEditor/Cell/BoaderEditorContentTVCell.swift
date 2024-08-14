//
//  BoaderEditorContentTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/14/24.
//

import UIKit

class BoaderEditorContentTVCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "내용"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    weak var delegate: BoardEditorCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .lp_background_white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        [titleLabel, mainView ].forEach {
            contentView.addSubview($0)
        }
        
        [contentTextView, textCountLabel].forEach {
            mainView.addSubview($0)
        }
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            mainView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
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
}

extension BoaderEditorContentTVCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(textView.text.count)/1000"
        delegate?.writeContent(content: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 백스페이스 확인
        if let char = text.cString(using: String.Encoding.utf8), strcmp(char, "\\b") == -92 {
            return true
        }
        
        // 최대 길이 확인
        if textView.text.count >= 1000 {
            return handleTextChange(textView, replacementText: text)
        }
        
        return true
    }
    
    private func handleTextChange(_ textView: UITextView, replacementText text: String) -> Bool {
        // 받침 여부에 따른 처리
        let hasPostPosition = postPositionText(textView.text)
        let isConsonantChar = isConsonant(Character(text))
        let isVowelChar = isVowel(Character(text))
        
        if !hasPostPosition && isConsonantChar {
            return textView.text.utf16.count + text.count < 1001 || !isVowelChar
        } else if hasPostPosition && !isConsonantChar {
            guard let lastText = textView.text.last else { return false }
            if isConsonant(lastText) {
                return true
            } else {
                return textView.text.count > 1001 ? isVowelChar : false
            }
        } else {
            return false
        }
    }
    
    private func postPositionText(_ inputText: String) -> Bool {
        guard let lastText = inputText.last else { return false }
        guard let unicodeVal = UnicodeScalar(String(lastText))?.value, 0xAC00...0xD7A3 ~= unicodeVal else {
            return false
        }
        let last = (unicodeVal - 0xAC00) % 28
        return last > 0
    }
    
    private func isConsonant(_ character: Character) -> Bool {
        guard let unicodeScalarValue = character.unicodeScalars.first?.value else { return false }
        return 0x3131...0x314E ~= unicodeScalarValue
    }
    
    private func isVowel(_ character: Character) -> Bool {
        guard let unicodeScalarValue = character.unicodeScalars.first?.value else { return false }
        return (0x314F...0x3163 ~= unicodeScalarValue) || unicodeScalarValue == 0x318D
    }
}


