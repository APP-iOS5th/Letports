//
//  ImageTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

class GatheringImageTVCell: UITableViewCell {
	
	private let gatheringImage: UIImageView = {
		let iv = UIImageView()
		iv.isUserInteractionEnabled = false
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		self.contentView.addSubview(gatheringImage)
		self.contentView.backgroundColor = .lp_background_white
		NSLayoutConstraint.activate([
			gatheringImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			gatheringImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			gatheringImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			gatheringImage.heightAnchor.constraint(equalToConstant: 200)
		])
	}
	
	func configureCell(data: GatheringDetailVM.GatheringHeader) {
		if let image = UIImage(named: data.gatheringImage) {
			gatheringImage.image = image
		} else {
			print("Image not found: \(data.gatheringImage)")
		}
	}
}
