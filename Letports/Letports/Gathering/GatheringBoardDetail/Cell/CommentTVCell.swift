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
		lb.text = "08/01 19:03"
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let nickNameLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 8)
		lb.text = "손흥민"
		lb.textColor = .lightGray
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let commentLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 10, weight: .bold)
		lb.textAlignment = .center
		lb.layer.borderWidth = 1
		lb.layer.cornerRadius = 10
		lb.text = """
올스타전 못뛰었쥬 토트넘에서 우승만 해보고 서울로 갈게요 그전까지 은퇴 ㄴㄴL
"""
		lb.layer.borderColor = UIColor.black.cgColor
		lb.clipsToBounds = true
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let nickNameCommentSV: UIStackView = {
		let sv = UIStackView()
		sv.axis = .vertical
		sv.spacing = 15
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
		[userImageView, nickNameCommentSV, createDateLabel].forEach {
			containerView.addSubview($0)
		}
		
		[nickNameLabel, commentLabel].forEach {
			nickNameCommentSV.addArrangedSubview($0)
		}
		self.contentView.backgroundColor = .lp_background_white
		self.containerView.backgroundColor = .white
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			containerView.heightAnchor.constraint(equalToConstant: 50),
			
			userImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 7),
			userImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 7),
			userImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 7),
			userImageView.widthAnchor.constraint(equalToConstant: 60),
			userImageView.heightAnchor.constraint(equalToConstant: 60),
			
			nickNameCommentSV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
			nickNameCommentSV.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor, constant: 3),
			
			createDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
			createDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
		])
	}

}
