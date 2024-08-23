//
//  ActionSheetView.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import UIKit

class ActionSheetView: UIView {
	
	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.cornerRadius = 20
		view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.clipsToBounds = true
		return view
	}()
	
	private let deleteIdBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("모임나가기", for: .normal)
		btn.setTitleColor(.black, for: .normal)
		return btn
	}()
	
	private let reportBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("모임 신고하기", for: .normal)
		btn.setTitleColor(.red, for: .normal)
		return btn
	}()
	
	private let cancelButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("취소", for: .normal)
		btn.setTitleColor(.black, for: .normal)
		btn.backgroundColor = .systemGray6
		return btn
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		backgroundColor = UIColor.black.withAlphaComponent(0.5)
		
		addSubview(containerView)
		containerView.addSubview(deleteIdBtn)
		containerView.addSubview(reportBtn)
		containerView.addSubview(cancelButton)
		
		containerView.translatesAutoresizingMaskIntoConstraints = false
		deleteIdBtn.translatesAutoresizingMaskIntoConstraints = false
		reportBtn.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			deleteIdBtn.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
			deleteIdBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			deleteIdBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			deleteIdBtn.heightAnchor.constraint(equalToConstant: 50),
			
			reportBtn.topAnchor.constraint(equalTo: deleteIdBtn.bottomAnchor),
			reportBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			reportBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			reportBtn.heightAnchor.constraint(equalToConstant: 50),
			
			cancelButton.topAnchor.constraint(equalTo: reportBtn.bottomAnchor, constant: 10),
			cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			cancelButton.heightAnchor.constraint(equalToConstant: 50),
			cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		
//		deleteIdBtn.addTarget(self, action: #selector(deleteIdBtnTap), for: .touchUpInside)
//		reportBtn.addTarget(self, action: #selector(reportBtnTap), for: .touchUpInside)
//		cancelButton.addTarget(self, action: #selector(cancelBtnTap), for: .touchUpInside)
	}
	
	
}

#Preview {
	ActionSheetView(frame: UIScreen.main.bounds)
}
