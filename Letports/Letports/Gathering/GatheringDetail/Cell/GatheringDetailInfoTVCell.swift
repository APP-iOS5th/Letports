//
//  GatheringInfoTViCell.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

final class GatheringDetailInfoTVCell: UITableViewCell {
	
	private var isExpanded = true
	private var expandedHeight: CGFloat = 0
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentView.backgroundColor = .lp_background_white
		calculateExpandedHeight()
		updateTextViewHeight()
	}
	
	private func calculateExpandedHeight() {
		let sizeThatFitsTextView = gatheringInfoTextView.sizeThatFits(CGSize(
			width: gatheringInfoTextView.frame.width,
			height: CGFloat.greatestFiniteMagnitude))
		expandedHeight = sizeThatFitsTextView.height
	}
	
	private func updateTextViewHeight() {
		let newHeight = isExpanded ? expandedHeight : 100
		gatheringInfoTextView.constraints.forEach { constraint in
			if constraint.firstAttribute == .height {
				constraint.constant = newHeight
			}
		}
	}
	
	func getHeight() -> CGFloat {
		return isExpanded ? expandedHeight + 60 : 160
	}
	
	private let gatheringInfoTextView: UITextView = {
		let tv = UITextView()
		tv.backgroundColor = .lp_white
		tv.layer.cornerRadius = 10
		tv.isUserInteractionEnabled = false
		tv.isScrollEnabled = false
		tv.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
		tv.translatesAutoresizingMaskIntoConstraints = false
		return tv
	}()
	
	private let toggleBtn: UIButton = {
		let btn = UIButton()
		btn.setTitle("▲", for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitleColor(.lpBlack, for: .normal)
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
		[gatheringInfoTextView, toggleBtn].forEach {
			self.contentView.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			gatheringInfoTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			gatheringInfoTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			gatheringInfoTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			toggleBtn.topAnchor.constraint(equalTo: gatheringInfoTextView.bottomAnchor, constant: 10),
			toggleBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			toggleBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
		
		toggleBtn.addTarget(self, action: #selector(toggleGatheringInfo), for: .touchUpInside)
		
	}
	
	func configure(with gatherInfo: String?) {
		gatheringInfoTextView.text = gatherInfo
		print("소개글 \(gatheringInfoTextView)")
	}
	
	// 접기버튼
	@objc private func toggleGatheringInfo() {
		isExpanded.toggle()
		
		UIView.animate(withDuration: 0.3) {
			self.updateTextViewHeight()
			self.toggleBtn.setTitle(self.isExpanded ? "▲" : "▼", for: .normal)
			self.layoutIfNeeded()
		}
		(superview as? UITableView)?.beginUpdates()
		(superview as? UITableView)?.endUpdates()
	}
}

