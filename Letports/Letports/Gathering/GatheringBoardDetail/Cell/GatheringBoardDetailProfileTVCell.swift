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
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 20
		iv.clipsToBounds = true
		iv.layer.borderWidth = 0.2
		iv.layer.borderColor = UIColor.black.cgColor
		iv.isUserInteractionEnabled = false
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()
	
	private let nickNameLabel: UILabel = {
		let lb = UILabel()
        lb.textColor = .lp_black
		lb.font = .lp_Font(.regular, size: 18)
		lb.isUserInteractionEnabled = false
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let createDateLabel: UILabel = {
		let lb = UILabel()
		lb.font = .lp_Font(.light, size: 8)
        lb.textColor = .lp_lightGray
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
			profileImageView.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 8),
			profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -8),
			profileImageView.widthAnchor.constraint(equalToConstant: 60),
			profileImageView.heightAnchor.constraint(equalToConstant: 60),
			
			nameDateSV.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
			nameDateSV.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			nameDateSV.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -16),
			
			self.contentView.heightAnchor.constraint(greaterThanOrEqualTo: profileImageView.heightAnchor, constant: 16)
		])
	}
	
	func configure(nickname: String, imageUrl: String, creatDate: String) {
		createDateLabel.text = creatDate
		nickNameLabel.text = nickname
		if let url = URL(string: imageUrl) {
			profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "person.circle.fill"))
		} else {
			profileImageView.image = UIImage(named: "person.circle.fill")
		}
	}
}
