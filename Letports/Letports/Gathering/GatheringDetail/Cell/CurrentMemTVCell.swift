//
//  currentMemTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

class CurrentMemTVCell: UITableViewCell {
	
	private let currentMem: UILabel = {
		let lb = UILabel()
		lb.text = "현재 인원"
        lb.textColor = .lp_black
		lb.font = .lp_Font(.regular, size: 16)
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		self.contentView.addSubview(currentMem)
		self.contentView.backgroundColor = .lp_background_white
		NSLayoutConstraint.activate([
			currentMem.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			currentMem.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			currentMem.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16)
		])
	}
}
