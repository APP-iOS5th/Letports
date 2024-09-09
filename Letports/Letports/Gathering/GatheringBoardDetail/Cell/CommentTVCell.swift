//
//  CommentTVCell.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

class CommentTVCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.layer.borderWidth = 0.5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let createDateLabel: UILabel = {
        let lb = UILabel()
		lb.font = .lp_Font(.regular, size: 8)
        lb.textColor = .lightGray
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let nickNameLabel: UILabel = {
        let lb = UILabel()
		lb.font = .lp_Font(.regular, size: 14)
        lb.textColor = .lp_black
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let commentLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 12)
        lb.textAlignment = .left
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()
    
    private let nickNameCommentSV: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
        commentLabel.preferredMaxLayoutWidth = commentLabel.frame.width
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
        userImageView.kf.cancelDownloadTask()
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        [userImageView, nickNameLabel, commentLabel, createDateLabel].forEach {
            containerView.addSubview($0)
        }
        
        self.contentView.backgroundColor = .lp_background_white
        self.containerView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            userImageView.widthAnchor.constraint(equalToConstant: 30),
            userImageView.heightAnchor.constraint(equalToConstant: 30),
            
            nickNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            nickNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            nickNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            nickNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            createDateLabel.centerYAnchor.constraint(equalTo: nickNameLabel.centerYAnchor),
            createDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            commentLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 5),
            commentLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            commentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
			commentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25)
        ])
    }
    
    func configureCell(with user: LetportsUser, comment: Comment) {
        let date = comment.createDate.dateValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        nickNameLabel.text = user.nickname
        createDateLabel.text = dateString
        commentLabel.text = comment.contents
        
        if let url = URL(string: user.image) {
            userImageView.kf.setImage(with: url,
                                      placeholder: UIImage(systemName: "person.circle"),
                                      options: [
                                        .transition(.fade(0.3)),
                                        .cacheOriginalImage
                                      ])
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
