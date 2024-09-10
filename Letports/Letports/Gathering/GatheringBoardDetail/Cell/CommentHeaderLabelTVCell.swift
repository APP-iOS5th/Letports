//
//  CommentLabelTVCell.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

class CommentHeaderLabelTVCell: UITableViewCell {
    
    private let commentHeaderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "댓글"
        lb.textColor = .lp_black
        lb.font = .lp_Font(.regular, size: 16)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let commentCountLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .lp_black
        lb.font = .lp_Font(.regular, size: 14)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
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
        [commentHeaderLabel, commentCountLabel].forEach {
            self.contentView.addSubview($0)
        }
        
        self.contentView.backgroundColor = .lp_background_white
        NSLayoutConstraint.activate([
            commentHeaderLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            commentHeaderLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            commentHeaderLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            
            commentCountLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            commentCountLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            commentCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: commentHeaderLabel.trailingAnchor, constant: 3),
        ])
    }
    
    func configure(count: Int) {
        commentCountLabel.text = "\(count)"
    }
}
