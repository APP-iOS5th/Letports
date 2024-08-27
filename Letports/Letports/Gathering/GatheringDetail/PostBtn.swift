//
//  FloatButton.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

class PostBtn: UIView {
	private let floatingButton: UIButton = {
		let btn = UIButton(type: .custom)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.backgroundColor = .lp_main
		btn.layer.cornerRadius = 30
		btn.clipsToBounds = true
		
		let plusLayer = CAShapeLayer()
		plusLayer.strokeColor = UIColor.white.cgColor
		plusLayer.lineWidth = 3
		plusLayer.fillColor = nil
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 20, y: 30))
		path.addLine(to: CGPoint(x: 40, y: 30))
		path.move(to: CGPoint(x: 30, y: 20))
		path.addLine(to: CGPoint(x: 30, y: 40))
		
		plusLayer.path = path.cgPath
		btn.layer.addSublayer(plusLayer)
		
		return btn
	}()
	
	let optionsStackView: UIStackView = {
		let sv = UIStackView()
		sv.axis = .vertical
		sv.spacing = 10
		sv.alignment = .trailing
		sv.translatesAutoresizingMaskIntoConstraints = false
		sv.isHidden = true
		return sv
	}()
	
	let postButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("게시글 등록", for: .normal)
		btn.backgroundColor = .white
		btn.layer.cornerRadius = 15
		btn.layer.borderWidth = 1
		btn.layer.borderColor = UIColor.lightGray.cgColor
		var configuration = UIButton.Configuration.plain()
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
		btn.configuration = configuration
		return btn
	}()
	
	let noticeButton: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("공지사항 등록", for: .normal)
		btn.backgroundColor = .white
		btn.layer.cornerRadius = 15
		btn.layer.borderWidth = 1
		btn.layer.borderColor = UIColor.lightGray.cgColor
		var configuration = UIButton.Configuration.plain()
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
		btn.configuration = configuration
		return btn
	}()
	
	var isMaster: Bool = false {
		didSet {
			updateButtonVisibility()
		}
	}
	
	var isOptionsStackViewHidden: Bool {
		get { optionsStackView.isHidden }
		set { optionsStackView.isHidden = newValue }
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		addSubview(floatingButton)
		addSubview(optionsStackView)
		
		optionsStackView.addArrangedSubview(postButton)
		optionsStackView.addArrangedSubview(noticeButton)
		
		NSLayoutConstraint.activate([
			floatingButton.trailingAnchor.constraint(equalTo: trailingAnchor),
			floatingButton.bottomAnchor.constraint(equalTo: bottomAnchor),
			floatingButton.widthAnchor.constraint(equalToConstant: 60),
			floatingButton.heightAnchor.constraint(equalToConstant: 60),
			
			optionsStackView.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor),
			optionsStackView.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -10)
		])
		
		floatingButton.addTarget(self, action: #selector(floatingBtnTapped), for: .touchUpInside)
		postButton.addTarget(self, action: #selector(postBtnTapped), for: .touchUpInside)
		noticeButton.addTarget(self, action: #selector(noticeBtnTapped), for: .touchUpInside)
	}
	
	private func updateButtonVisibility() {
		noticeButton.isHidden = !isMaster
	}
	
	func setVisible(_ isVisible: Bool) {
		self.isHidden = !isVisible
	}
	
	@objc func floatingBtnTapped() {
		UIView.animate(withDuration: 0.3) {
			self.optionsStackView.isHidden.toggle()
		}
	}
	
	@objc func postBtnTapped() {
		print("게시글 등록 버튼이 탭되었습니다.")
		isOptionsStackViewHidden = true
	}
	
	@objc func noticeBtnTapped() {
		print("공지사항 등록 버튼이 탭되었습니다.")
		isOptionsStackViewHidden = true
	}
}
