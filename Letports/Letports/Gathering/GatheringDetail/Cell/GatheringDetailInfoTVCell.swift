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
		tv.text = """
🖤❤️ 수호신은 FC 서울을 응원하는 서포터즈 🖤❤️

⚽️🏟️주로 골대 뒤에서 응원을 하지만  👩‍❤️‍👨FC 서울을 응원하고 사랑한다면 누구든 수호신

✅ 가입대상
☝️️ 서울을 사랑한다면 👌
✌️ 혼자가기 고민했다면 👌

✅ 가입 조건
☝️️ 개랑, 매북, 통산, 싸천, 징구, 빵집, 남패 금지
🚫🚯☝️️ 개랑, 매북, 통산, 싸천, 징구, 빵집, 남패 금지
🚫🚯☝️️ 개랑, 매북, 통산, 싸천, 징구, 빵집, 남패 금지
🚫🚯☝️️ 개랑, 매북, 통산, 싸천, 징구, 빵집, 남패 금지
🚫🚯☝️️ 개랑, 매북, 통산, 싸천, 징구, 빵집, 남패 금지
"""
		return tv
	}()
	
	private let toggleButton: UIButton = {
		let bt = UIButton()
		bt.setTitle("▲", for: .normal)
		bt.translatesAutoresizingMaskIntoConstraints = false
		bt.setTitleColor(.lpBlack, for: .normal)
		return bt
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
		[gatheringInfoTextView, toggleButton].forEach {
			self.contentView.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			gatheringInfoTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			gatheringInfoTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			gatheringInfoTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			toggleButton.topAnchor.constraint(equalTo: gatheringInfoTextView.bottomAnchor, constant: 10),
			toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			toggleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
		
		toggleButton.addTarget(self, action: #selector(toggleGatheringInfo), for: .touchUpInside)
		
	}
	
	// 접기버튼
	@objc private func toggleGatheringInfo() {
		isExpanded.toggle()
		
		UIView.animate(withDuration: 0.3) {
			self.updateTextViewHeight()
			self.toggleButton.setTitle(self.isExpanded ? "▲" : "▼", for: .normal)
			self.layoutIfNeeded()
		}
		(superview as? UITableView)?.beginUpdates()
		(superview as? UITableView)?.endUpdates()
	}
}

