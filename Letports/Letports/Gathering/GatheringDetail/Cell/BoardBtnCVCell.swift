//
//  BoardButtonCVCell.swift
//  Letports
//
//  Created by Yachae on 8/18/24.
//

import UIKit

class BoardBtnCVCell: UICollectionViewCell {
	
	private var boardButtonType: PostType = .all
	private var teamColor: String?
	private let boardSelectButton: UIButton = {
		var config = UIButton.Configuration.plain()
		config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
		let btn = UIButton(configuration: config, primaryAction: nil)
		btn.clipsToBounds = true
		btn.layer.cornerRadius = 10
		btn.layer.borderWidth = 0.2
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	weak var delegate: ButtonStateDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	private func setupUI() {
		contentView.addSubview(boardSelectButton)
		boardSelectButton.addTarget(self, action: #selector(boardBtnTap), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			boardSelectButton.heightAnchor.constraint(equalToConstant: 22),
			boardSelectButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			boardSelectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		])
	}
	
	func updateButtonUI(isSelected: Bool) {
		var configuration = boardSelectButton.configuration
		var attributedTitle = AttributedString(boardButtonType.title)
		attributedTitle.font = .lp_Font(.regular, size: 14)
		configuration?.attributedTitle = attributedTitle
		if isSelected {
			boardSelectButton.backgroundColor = UIColor(hex: teamColor ?? "")
			configuration?.baseForegroundColor = .white
		} else {
			boardSelectButton.backgroundColor = .lp_white
			configuration?.baseForegroundColor = .black
		}
		self.boardSelectButton.configuration = configuration
	}
	
	private func tapGesture() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTap))
		self.contentView.addGestureRecognizer(tapGesture)
		self.contentView.isUserInteractionEnabled = true
	}
	
    func configure(with type: PostType, teamColor: String) {
		self.boardButtonType = type
        self.teamColor = teamColor
	}
	// 게시판 선택 버튼(3개)
	@objc private func boardBtnTap() {
		delegate?.didChangeButtonState(boardSelectButton, isSelected: true)
	}
	// 게시글 셀 클릭
	@objc private func cellTap() {
		boardBtnTap()
	}
}
