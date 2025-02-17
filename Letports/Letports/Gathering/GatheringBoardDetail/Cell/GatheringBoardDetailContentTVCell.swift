//
//  GatheringBoardDetailProfileTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

final class GatheringBoardDetailContentTVCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .lp_black
        lb.font = .lp_Font(.regular, size: 22)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .lp_white
        tv.layer.cornerRadius = 10
        tv.isUserInteractionEnabled = false
        tv.font = .lp_Font(.regular, size: 14)
        tv.textColor = .lp_black
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 50, left: 16, bottom: 50, right: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupUI()
    private func setupUI() {
        self.contentView.backgroundColor = .lp_background_white
        [contentTextView, titleLabel].forEach {
            self.contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            contentTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: contentTextView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with post: Post) {
        titleLabel.text = post.title
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attributedText = NSAttributedString(
            string: post.contents,
            attributes: [
                .font: UIFont.lp_Font(.regular, size: 14),
                .foregroundColor: UIColor.lp_black,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        contentTextView.attributedText = attributedText
    }
}
