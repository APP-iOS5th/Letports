//
//  GatheringBoardUploadInfoTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit

class GatheringUploadInfoTVCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "모임 소개"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .lp_white
        tv.layer.cornerRadius = 10
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/1000"
        label.textColor = .lp_gray
        label.font = .systemFont(ofSize: 10)
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
        [titleLabel, contentTextView, textCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 250),
            textCountLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 14),
            textCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            textCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            textCountLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
    }
    
    
    
}

extension GatheringUploadInfoTVCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(textView.text.count)/1000"
        self.delegate?.sendGatehrInfo(content: contentTextView.text)
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
