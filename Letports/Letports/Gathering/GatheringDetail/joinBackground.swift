//
//  joinBackground.swift
//  Letports
//
//  Created by Yachae on 8/23/24.
//

import UIKit

class JoinBackgroundView: UIView {
	
	// 초기화 메서드
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	// 뷰 설정 메서드
	private func setupView() {
		self.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 반투명한 검정색 배경
		self.translatesAutoresizingMaskIntoConstraints = false
	}
}
