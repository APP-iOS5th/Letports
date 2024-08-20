//
//  ProfileCVC.swift
//  Letports
//
//  Created by Yachae on 8/12/24.
//

import UIKit

final class GatheringDetailProfileCVCell: UICollectionViewCell {
	
	private let userImageBt: UIButton = {
		let bt = UIButton()
		bt.contentMode = .scaleAspectFill
		bt.clipsToBounds = true
		bt.layer.cornerRadius = 22.5
		bt.layer.borderWidth = 0.5
		bt.layer.borderColor = UIColor.black.cgColor
		bt.widthAnchor.constraint(equalToConstant: 45).isActive = true
		bt.heightAnchor.constraint(equalToConstant: 45).isActive = true
		return bt
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
		[userImageBt, userNickName].forEach {
			self.verticalStack.addArrangedSubview($0)
		}
		
		contentView.addSubview(verticalStack)
		NSLayoutConstraint.activate([
			verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			verticalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
		
		userImageBt.addTarget(self, action: #selector(imageTap), for: .touchUpInside)
	}
	
	func configure(profile: GatheringDetailVM.Profile) {
		self.userImageBt.setImage(UIImage(named: profile.userImage), for: .normal)
		 self.userNickName.text = profile.userNickName
	 }
	
	@objc private func imageTap() {
		// 이미지 버튼 클릭 시 동작 정의
		print("이미지 버튼이 클릭되었습니다.")
	}
}
