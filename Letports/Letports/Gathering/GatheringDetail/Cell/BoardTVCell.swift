//
//  SelectBoardTVCell.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

final class BoardTVCell: UITableViewCell {
	
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 15
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.lightGray.cgColor
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 10)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let createDateLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 8)
		label.textColor = .lightGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let boardTypeLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 10, weight: .bold)
		label.textAlignment = .center
		label.layer.borderWidth = 1
		label.layer.cornerRadius = 10
		label.layer.borderColor = UIColor.black.cgColor
		label.clipsToBounds = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override func layoutSubviews() {
		super.layoutSubviews()
		contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
		tapGesture()
		self.selectionStyle = .none
		self.backgroundColor = .clear // 셀의 배경을 투명하게 설정
		self.contentView.backgroundColor = .clear
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	private func setupUI() {
		contentView.addSubview(containerView)
		[boardTypeLabel, titleLabel, createDateLabel].forEach {
			containerView.addSubview($0)
		}
		self.contentView.backgroundColor = .lp_background_white
		self.containerView.backgroundColor = .white
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			containerView.heightAnchor.constraint(equalToConstant: 50),
			
			boardTypeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
			boardTypeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			boardTypeLabel.widthAnchor.constraint(equalToConstant: 50),
			boardTypeLabel.heightAnchor.constraint(equalToConstant: 20),
			
			titleLabel.leadingAnchor.constraint(equalTo: boardTypeLabel.trailingAnchor, constant: 10),
			titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			
			createDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
			createDateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
		])
	}
	
	private func tapGesture() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTap))
		self.contentView.addGestureRecognizer(tapGesture)
		self.contentView.isUserInteractionEnabled = true
	}
	
	func configureCell(data: GatheringDetailVM.BoardData) {
		createDateLabel.text = data.createDate
		boardTypeLabel.text = data.boardType.description
		titleLabel.text = data.title
	}
	
	@objc private func cellTap() {
		print("셀이 눌렸습니다")
	}
}



