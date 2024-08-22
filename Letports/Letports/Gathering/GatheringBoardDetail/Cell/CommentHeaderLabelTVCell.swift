//
//  CommentLabelTVCell.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

class CommentHeaderLabelTVCell: UITableViewCell {
	
	private let commentHeaderLabel: UILabel = {
		let lb = UILabel()
		lb.text = "댓글"
		lb.font = UIFont.boldSystemFont(ofSize: 16)
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
	
	// MARK: - setupUI()
	
	private func setupUI() {
		self.contentView.addSubview(commentHeaderLabel)
		self.contentView.backgroundColor = .lp_background_white
		NSLayoutConstraint.activate([
			commentHeaderLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			commentHeaderLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
			commentHeaderLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16)
		])
	}
}
