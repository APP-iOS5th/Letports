//
//  SelectBoardTVCell.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

protocol BoardTVCellDelegate: AnyObject {
	func didTapBoardCell(_ cell: BoardTVCell, boardPost: BoardPost)
}

final class BoardTVCell: UITableViewCell {
	
	weak var delegate: BoardTVCellDelegate?
	private var boardPost: BoardPost?
	
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 15
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.lightGray.cgColor
		return view
	}()
	
	private let titleLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 10)
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let createDateLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 8)
		lb.textColor = .lightGray
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let boardTypeLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 10, weight: .bold)
		lb.textAlignment = .center
		lb.layer.borderWidth = 1
		lb.layer.cornerRadius = 10
		lb.layer.borderColor = UIColor.black.cgColor
		lb.clipsToBounds = true
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
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
		self.backgroundColor = .clear 
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
	
	func configureCell(data: BoardPost) {
//		createDateLabel.text = data.createDate (데이터 없음)
		self.boardPost = data
		switch data.boardType {
		   case "Free":
			   boardTypeLabel.text = "자유"
		   case "Noti":
			   boardTypeLabel.text = "공지"
		   default:
			   boardTypeLabel.text = "전체"
		   }
		titleLabel.text = data.contents
	}
	
	@objc private func cellTap() {
		guard let boardPost = boardPost else { return }
		delegate?.didTapBoardCell(self, boardPost: boardPost)
	}
}



