//
//  FloatButton.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

class PostBtn: UIView {
	private let floatingButton: UIButton = {
		let bt = UIButton(type: .custom)
		bt.translatesAutoresizingMaskIntoConstraints = false
		bt.backgroundColor = .lp_main
		bt.layer.cornerRadius = 30
		bt.clipsToBounds = true
		
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
		bt.layer.addSublayer(plusLayer)
		
		return bt
	}()
	
	private let optionsStackView: UIStackView = {
		let sv = UIStackView()
		sv.axis = .vertical
		sv.spacing = 10
		sv.alignment = .trailing
		sv.translatesAutoresizingMaskIntoConstraints = false
		sv.isHidden = true
		return sv
	}()
	
	private let postButton: UIButton = {
		let bt = UIButton(type: .system)
		bt.setTitle("게시글 등록", for: .normal)
		bt.backgroundColor = .white
		bt.layer.cornerRadius = 15
		bt.layer.borderWidth = 1
		bt.layer.borderColor = UIColor.lightGray.cgColor
		var configuration = UIButton.Configuration.plain()
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
		bt.configuration = configuration
		return bt
	}()
	
	private let noticeButton: UIButton = {
		let bt = UIButton(type: .system)
		bt.setTitle("공지사항 등록", for: .normal)
		bt.backgroundColor = .white
		bt.layer.cornerRadius = 15
		bt.layer.borderWidth = 1
		bt.layer.borderColor = UIColor.lightGray.cgColor
		var configuration = UIButton.Configuration.plain()
		configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
		bt.configuration = configuration
		return bt
	}()
	
	var isMaster: Bool = false {
		didSet {
			updateButtonVisibility()
		}
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
		
		floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
		postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
		noticeButton.addTarget(self, action: #selector(noticeButtonTapped), for: .touchUpInside)
	}
	
	private func updateButtonVisibility() {
		noticeButton.isHidden = !isMaster
	}
	
	func setVisible(_ isVisible: Bool) {
		self.isHidden = !isVisible
	}
	
	@objc private func floatingButtonTapped() {
		UIView.animate(withDuration: 0.3) {
			self.optionsStackView.isHidden.toggle()
		}
	}
	
	@objc private func postButtonTapped() {
		print("게시글 등록 버튼이 탭되었습니다.")
		optionsStackView.isHidden = true
	}
	
	@objc private func noticeButtonTapped() {
		print("공지사항 등록 버튼이 탭되었습니다.")
		optionsStackView.isHidden = true
	}
}
