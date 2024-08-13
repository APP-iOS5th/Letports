//
//  BoardTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

class BoardTVC: UITableViewCell {
	
	private let containerView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 10
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.lightGray.cgColor
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let boardTypeLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .systemRed
		label.textColor = .white
		label.font = UIFont.boldSystemFont(ofSize: 12)
		label.textAlignment = .center
		label.layer.cornerRadius = 10
		label.clipsToBounds = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.textAlignment = .left
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let dateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12)
		label.textColor = .gray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let boardSV: UIStackView = {
		let sv = UIStackView()
		sv.axis = .horizontal
		sv.spacing = 8
		sv.alignment = .center
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupLayout() {
		contentView.addSubview(containerView)
		containerView.addSubview(boardSV)
		containerView.addSubview(dateLabel)
		
		boardSV.addArrangedSubview(boardTypeLabel)
		boardSV.addArrangedSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			containerView.heightAnchor.constraint(equalToConstant: 49),
			containerView.widthAnchor.constraint(equalToConstant: 375),
			
			boardTypeLabel.widthAnchor.constraint(equalToConstant: 50),
			boardTypeLabel.heightAnchor.constraint(equalToConstant: 20),
			
			boardSV.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			boardSV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
			boardSV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
			
			dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
			dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
		])
	}
}

