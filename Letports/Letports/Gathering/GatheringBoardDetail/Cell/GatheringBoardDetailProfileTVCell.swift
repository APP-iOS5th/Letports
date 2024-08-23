//
//  GatheringBoardDetailProfileTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit
import Kingfisher

final class GatheringBoardDetailProfileTVCell: UITableViewCell {
	
	private let profileImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFit
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 20
		iv.layer.borderWidth = 0.2
		iv.layer.borderColor = UIColor.black.cgColor
		iv.widthAnchor.constraint(equalToConstant: 60).isActive = true
		iv.heightAnchor.constraint(equalToConstant: 60).isActive = true
		iv.isUserInteractionEnabled = false
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()
	
	private let nickNameLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 18, weight: .semibold)
		lb.isUserInteractionEnabled = false
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let createDateLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 8, weight: .regular)
		lb.text = "08/01"
		lb.textColor = .lightGray
		lb.isUserInteractionEnabled = false
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let nameDateSV: UIStackView = {
		let sv = UIStackView()
		sv.translatesAutoresizingMaskIntoConstraints = false
		sv.axis = .vertical
		sv.spacing = 10
		sv.alignment = .leading
		return sv
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: -  setupUI
	private func setupUI() {
		self.contentView.backgroundColor = .lp_background_white
		
		[profileImageView, nameDateSV].forEach {
			self.contentView.addSubview($0)
		}
		
		[nickNameLabel, createDateLabel].forEach {
			self.nameDateSV.addArrangedSubview($0)
		}
		NSLayoutConstraint.activate([
			profileImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			profileImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			
			nameDateSV.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
			nameDateSV.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			nameDateSV.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
		])
	}
	
//	func configure(with gathering: Gathering) {
//		nickNameLabel.text = post.title
//	}
}
