//
//  ProfileCVC.swift
//  Letports
//
//  Created by Yachae on 8/12/24.
//

import UIKit

protocol GatheringDetailProfileCVCellDelegate: AnyObject {
	func didTapProfile(member: GatheringMember)
}

final class GatheringDetailProfileCVCell: UICollectionViewCell {
	
	weak var delegate: GatheringDetailProfileCVCellDelegate?
	private var profile: GatheringMember?
	
	private let userImageBtn: UIButton = {
		let btn = UIButton()
		btn.contentMode = .scaleAspectFill
		btn.clipsToBounds = true
		btn.layer.cornerRadius = 22.5
		btn.layer.borderWidth = 0.5
		btn.layer.borderColor = UIColor.black.cgColor
		btn.widthAnchor.constraint(equalToConstant: 45).isActive = true
		btn.heightAnchor.constraint(equalToConstant: 45).isActive = true
		return btn
	}()
	
	private let userNickName: UILabel = {
		let lb = UILabel()
		lb.textAlignment = .center
		lb.font = .systemFont(ofSize: 10, weight: .medium)
		return lb
	}()
	
	private let verticalStack: UIStackView = {
		let sv = UIStackView()
		sv.axis = .vertical
		sv.alignment = .center
		sv.spacing = 5
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	private func setupUI() {
		[userImageBtn, userNickName].forEach {
			self.verticalStack.addArrangedSubview($0)
		}
		
		contentView.addSubview(verticalStack)
		NSLayoutConstraint.activate([
			verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			verticalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
		
		userImageBtn.addTarget(self, action: #selector(imageTap), for: .touchUpInside)
	}
	
	func configure(member: GatheringMember) {
		self.profile = member
		self.userNickName.text = member.nickName
		if let url = URL(string: member.image) {
			userImageBtn.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "placeholder_image"))
		}
	}
	
	@objc private func imageTap() {
		guard let profile = profile else { return }
		delegate?.didTapProfile(member: profile)
	}
}
