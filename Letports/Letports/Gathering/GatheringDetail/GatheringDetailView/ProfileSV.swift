//
//  ProfileSV.swift
//  Letports
//
//  Created by Yachae on 8/12/24.
//

import UIKit

class ProfileSV: UIScrollView {
	
	private let profiles: [Profile]
	
	init(profiles: [Profile]) {
		self.profiles = profiles
		super.init(frame: .zero)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		translatesAutoresizingMaskIntoConstraints = false
		showsHorizontalScrollIndicator = false
		
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .equalSpacing
		stackView.spacing = 20
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		for profile in profiles {
			let profileView = createProfileView(profile: profile)
			stackView.addArrangedSubview(profileView)
		}
		
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			stackView.heightAnchor.constraint(equalTo: heightAnchor)
		])
	}
	
	private func createProfileView(profile: Profile) -> UIView {
		let userImage = createButton(imageName: profile.userImage)
		let userNickName = createLabel(text: profile.userNickName)
		let verticalStack = UIStackView(arrangedSubviews: [userImage, userNickName])
		verticalStack.axis = .vertical
		verticalStack.alignment = .center
		verticalStack.spacing = 5
		
		return verticalStack
	}
	
	private func createButton(imageName: String) -> UIButton {
		let button = UIButton()
		button.setImage(UIImage(named: imageName), for: .normal)
		button.contentMode = .scaleAspectFill
		button.clipsToBounds = true
		button.layer.cornerRadius = 22.5
		button.layer.borderWidth = 0.5
		button.layer.borderColor = UIColor.black.cgColor
		button.widthAnchor.constraint(equalToConstant: 45).isActive = true
		button.heightAnchor.constraint(equalToConstant: 45).isActive = true
		button.addTarget(self, action: #selector(proFilebuttonTap), for: .touchUpInside)
		
		return button
	}
	
	private func createLabel(text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		return label
	}
	
	@objc private func proFilebuttonTap() {
		// 버튼 클릭 시 동작 정의
	}
}

