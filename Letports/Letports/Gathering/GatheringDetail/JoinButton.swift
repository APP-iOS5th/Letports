//
//  FloatingButton.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

// Floating button class
class JoinButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupButton()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupButton() {
		self.setTitle("가입하기", for: .normal)
		self.backgroundColor = .black
		self.setTitleColor(.white, for: .normal)
		self.layer.cornerRadius = 25
		self.clipsToBounds = true
	}
}
