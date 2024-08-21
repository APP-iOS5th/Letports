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
		iv.contentMode = .scaleAspectFit
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 10
		iv.layer.borderWidth = 0.5
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()
	
	private let createDateLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 8)
		lb.textColor = .lightGray
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let nickNameLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 14)
		lb.textColor = .black
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let commentLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 10)
		lb.textAlignment = .left
		lb.numberOfLines = 2
		lb.lineBreakMode = .byTruncatingTail
		lb.translatesAutoresizingMaskIntoConstraints = false
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
			userImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			userImageView.widthAnchor.constraint(equalToConstant: 60),
			userImageView.heightAnchor.constraint(equalToConstant: 60),
			
			nickNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
			nickNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
			
			commentLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor),
			commentLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
			commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
			commentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
			
			createDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
			createDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
		])
	}
	
	func configureCell(data: GatheringBoardDetailVM.Comment) {
		// 임시 주석처리
		userImageView.image = UIImage(named: "defaultUserImage")
		nickNameLabel.text = data.nickName
		commentLabel.text = data.content
		createDateLabel.text = data.writeDate
	}
	
}
