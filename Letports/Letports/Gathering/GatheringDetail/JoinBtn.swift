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
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = .lp_Font(.regular, size: 16)
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
    
    func configure(logoHex: String?) {
        self.backgroundColor = UIColor(hex: logoHex ?? "")
    }
}
