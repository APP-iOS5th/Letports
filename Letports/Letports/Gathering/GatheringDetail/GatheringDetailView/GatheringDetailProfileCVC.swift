//
//  ProfileCVC.swift
//  Letports
//
//  Created by Yachae on 8/12/24.
//

import UIKit

class GatheringDetailProfileCVC: UICollectionViewCell {
	private let userImage = UIButton()
	private let userNickName = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		userImage.contentMode = .scaleAspectFill
		userImage.clipsToBounds = true
		userImage.layer.cornerRadius = 22.5
		userImage.layer.borderWidth = 0.5
		userImage.layer.borderColor = UIColor.black.cgColor
		userImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
		userImage.heightAnchor.constraint(equalToConstant: 45).isActive = true
		
		userNickName.textAlignment = .center
		userNickName.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		
		let verticalStack = UIStackView(arrangedSubviews: [userImage, userNickName])
		verticalStack.axis = .vertical
		verticalStack.alignment = .center
		verticalStack.spacing = 5
		
		contentView.addSubview(verticalStack)
		verticalStack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			verticalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	func configure(profile: Profile) {
		userImage.setImage(UIImage(named: profile.userImage), for: .normal)
		userNickName.text = profile.userNickName
	}
}
