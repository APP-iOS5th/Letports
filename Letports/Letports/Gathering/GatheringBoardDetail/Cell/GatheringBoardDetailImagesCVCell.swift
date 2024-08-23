//
//  GatheringBoardDetailImagesCVCell.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

class GatheringBoardDetailImagesCVCell: UICollectionViewCell {
	
	private let imageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 40
		iv.image = UIImage(named: "sampleImage")
		iv.layer.borderWidth = 0.5
		iv.translatesAutoresizingMaskIntoConstraints = false
		
		return iv
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		contentView.layer.cornerRadius = 40
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - setupUI
	private func setupUI() {
		self.contentView.addSubview(imageView)
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	func configure(with imageUrl: String) {
		  if let url = URL(string: imageUrl) {
			  imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder_image"))
		  }
	  }
}
