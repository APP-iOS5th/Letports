//
//  BoardTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

class BoardTVC: UITableViewCell {
	
	private let containerView = UIView()
	private let boardTypeLabel = UILabel()
	private let titleLabel = UILabel()
	private let dateLabel = UILabel()
	private let contentsLabel = UILabel()
	private let boardSV = UIStackView()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupLayout() {
		containerView.layer.cornerRadius = 10
		containerView.layer.borderWidth = 1
		containerView.layer.borderColor = UIColor.lightGray.cgColor
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.widthAnchor.constraint(equalToConstant: 375).isActive = true
		containerView.heightAnchor.constraint(equalToConstant: 49).isActive = true
	
		boardTypeLabel.backgroundColor = .systemRed
		boardTypeLabel.textColor = .black
		boardTypeLabel.font = UIFont.boldSystemFont(ofSize: 12)
		boardTypeLabel.layer.borderWidth = 0.5
		boardTypeLabel.textAlignment = .center
		boardTypeLabel.layer.cornerRadius = 10
		boardTypeLabel.clipsToBounds = true
		boardTypeLabel.translatesAutoresizingMaskIntoConstraints = false
		boardTypeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
		boardTypeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		titleLabel.font = UIFont.systemFont(ofSize: 10)
		titleLabel.textAlignment = .left
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		boardTypeLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
		boardTypeLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
		
		dateLabel.font = UIFont.systemFont(ofSize: 8)
		dateLabel.textColor = .gray
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		boardTypeLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
		boardTypeLabel.heightAnchor.constraint(equalToConstant: 6).isActive = true
		
	}
	
	func configure(type: String, title: String, date: String) {
		boardTypeLabel.text = type
		titleLabel.text = title
		dateLabel.text = date
	}
}
