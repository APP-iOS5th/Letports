//
//  BoardButtonCVCell.swift
//  Letports
//
//  Created by Yachae on 8/18/24.
//

import UIKit

class BoardButtonCVCell: UICollectionViewCell {
	
	private var boardButtonType: BoardButtonType = .all
	
	let boardSelectButton: UIButton = {
		var config = UIButton.Configuration.plain()
		config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
		let bt = UIButton(configuration: config, primaryAction: nil)
		bt.clipsToBounds = true
		bt.layer.cornerRadius = 11
		bt.layer.borderWidth = 0.5
		bt.layer.borderColor = UIColor.lp_lightGray.cgColor
		bt.backgroundColor = .lp_white
		bt.translatesAutoresizingMaskIntoConstraints = false
		return bt
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
		boardSelectButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)

		NSLayoutConstraint.activate([
			boardSelectButton.heightAnchor.constraint(equalToConstant: 22),
			boardSelectButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			boardSelectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		])
	}
	
	func updateButtonUI(isSelected: Bool) {
		switch boardButtonType {
		case .all:
			boardSelectButton.setTitle("전체", for: .normal)
		case .noti:
			boardSelectButton.setTitle("공지", for: .normal)
		case .free:
			boardSelectButton.setTitle("자유게시판", for: .normal)
		}
		
		if isSelected {
			boardSelectButton.backgroundColor = .black
			boardSelectButton.setTitleColor(.white, for: .normal)
		} else {
			boardSelectButton.backgroundColor = .lp_white
			boardSelectButton.setTitleColor(.black, for: .normal)
		}
	}
	
	func configure(with type: BoardButtonType) {
		self.boardButtonType = type
	}
	
	@objc private func buttonTap() {
		delegate?.didChangeButtonState(boardSelectButton, isSelected: true)
	}
}
