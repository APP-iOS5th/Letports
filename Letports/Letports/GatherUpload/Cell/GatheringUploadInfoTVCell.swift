//
//  GatheringBoardUploadInfoTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit
import KoTextCountLimit

class GatheringUploadInfoTVCell: UITableViewCell {
    private let koTextLimit = KoTextCountLimit()
    
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
    
    func configureCell(infoText: String?) {
        guard let infoText = infoText else { return }
        self.contentTextView.text = infoText
        self.textCountCheck(text: infoText)
    }
    
    private func textCountCheck(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.textCountLabel.text = "\(text.count)/1000"
        }
    }
}

extension GatheringUploadInfoTVCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textCountCheck(text: textView.text)
        self.delegate?.sendGatehrInfo(content: contentTextView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return koTextLimit.shouldChangeText(for: textView, in: range, replacementText: text, maxCharacterLimit: 1000)
    }
}
