//
//  GatheringInfoTViCell.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

final class GatheringDetailInfoTVCell: UITableViewCell {
	
	var expandBtnTap: ((Bool) -> Void) = { _ in }
	private var isExpanded = false
	private let maxCollapsedHeight: CGFloat = 100
	private var textViewHeightConstraint: NSLayoutConstraint?
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentView.backgroundColor = .lp_background_white
	}
	
	private let gatheringInfoTextView: UITextView = {
		let tv = UITextView()
		tv.backgroundColor = .lp_white
		tv.layer.cornerRadius = 10
		tv.isUserInteractionEnabled = false
		tv.isScrollEnabled = false
		tv.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
		tv.textContainer.lineBreakMode = .byTruncatingTail
		tv.translatesAutoresizingMaskIntoConstraints = false
		return tv
	}()
	
	private let expandBtn: UIButton = {
		let btn = UIButton()
		btn.setTitle("더보기", for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitleColor(.lp_black, for: .normal)
		return btn
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	private func setupUI() {
		[gatheringInfoTextView, expandBtn].forEach {
			self.contentView.addSubview($0)
		}
		
		textViewHeightConstraint = gatheringInfoTextView.heightAnchor.constraint(equalToConstant: maxCollapsedHeight)
		textViewHeightConstraint?.isActive = true
		
		NSLayoutConstraint.activate([
			gatheringInfoTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			gatheringInfoTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			gatheringInfoTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			expandBtn.topAnchor.constraint(equalTo: gatheringInfoTextView.bottomAnchor, constant: 5),
			expandBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			expandBtn.heightAnchor.constraint(equalToConstant: 30),
			expandBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
		])
		
		expandBtn.addTarget(self, action: #selector(expandInfo), for: .touchUpInside)
		
	}
	
	func configure(with gatherInfo: String?) {
		gatheringInfoTextView.text = gatherInfo
		layoutIfNeeded()
		updateExpandButtonVisibility()
	}
	
	private func updateExpandButtonVisibility() {
		let size = gatheringInfoTextView.sizeThatFits(CGSize(width: gatheringInfoTextView.frame.width,
															 height: .greatestFiniteMagnitude))
		expandBtn.isHidden = size.height <= maxCollapsedHeight
	}
	
	@objc func expandInfo() {
		isExpanded.toggle()
		if isExpanded {
			textViewHeightConstraint?.isActive = false
			expandBtn.setTitle("접기", for: .normal)
		} else {
			textViewHeightConstraint?.isActive = true
			expandBtn.setTitle("더보기", for: .normal)
		}
		expandBtnTap(isExpanded)
	}
}

