//
//  FloatingButton.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

class JoinBtn: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupBtn()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupBtn() {
		self.setTitle("가입하기", for: .normal)
		self.backgroundColor = .black
		self.setTitleColor(.white, for: .normal)
		self.layer.cornerRadius = 0
		self.clipsToBounds = true
	}
}
