//
//  CommentInput.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

class CommentInputView: UIView {
	
	private let textField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "댓글을 입력하세요"
		tf.borderStyle = .roundedRect
		tf.clipsToBounds = true
		tf.layer.cornerRadius = 10
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	private let registBtn: UIButton = {
		let btn = UIButton()
		btn.setTitle("등록", for: .normal)
		btn.setTitleColor(.black, for: .normal)
		btn.clipsToBounds = true
		btn.layer.cornerRadius = 10
		btn.backgroundColor = .lp_white
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	private let textFieldSV: UIStackView = {
		let sv = UIStackView()
		sv.axis = .horizontal
		sv.distribution = .fill
		sv.spacing = 10
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - setupUI()
	private func setupUI() {
		addSubview(textFieldSV)
		
		[textField, registBtn].forEach {
			textFieldSV.addArrangedSubview($0)
		}
		
		NSLayoutConstraint.activate([
			textFieldSV.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			textFieldSV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			textFieldSV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			textFieldSV.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
			
			registBtn.widthAnchor.constraint(equalToConstant: 60)
		])
	}
}
