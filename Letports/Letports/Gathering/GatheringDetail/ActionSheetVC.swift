//
//  ActionSheetView.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import UIKit

protocol ActionSheetViewDelegate: AnyObject {
	func didTapLeaveGathering()
	func didTapReportGathering()
	func didTapCancel()
}

class ActionSheetVC: UIViewController {
	weak var delegate: ActionSheetViewDelegate?
	
	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.cornerRadius = 20
		view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.clipsToBounds = true
		return view
	}()
	
	private let leaveButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("모임나가기", for: .normal)
		button.setTitleColor(.black, for: .normal)
		return button
	}()
	
	private let reportButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("모임 신고하기", for: .normal)
		button.setTitleColor(.red, for: .normal)
		return button
	}()
	
	private let cancelButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("취소", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = .systemGray6
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	private func setupView() {
		view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		
		view.addSubview(containerView)
		containerView.addSubview(leaveButton)
		containerView.addSubview(reportButton)
		containerView.addSubview(cancelButton)
		
		containerView.translatesAutoresizingMaskIntoConstraints = false
		leaveButton.translatesAutoresizingMaskIntoConstraints = false
		reportButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			leaveButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
			leaveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			leaveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			leaveButton.heightAnchor.constraint(equalToConstant: 50),
			
			reportButton.topAnchor.constraint(equalTo: leaveButton.bottomAnchor),
			reportButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			reportButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			reportButton.heightAnchor.constraint(equalToConstant: 50),
			
			cancelButton.topAnchor.constraint(equalTo: reportButton.bottomAnchor, constant: 10),
			cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			cancelButton.heightAnchor.constraint(equalToConstant: 50),
			cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		
		leaveButton.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
		reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
		cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
	}
	
	@objc private func leaveButtonTapped() {
		delegate?.didTapLeaveGathering()
	}
	
	@objc private func reportButtonTapped() {
		delegate?.didTapReportGathering()
	}
	
	@objc private func cancelButtonTapped() {
		delegate?.didTapCancel()
		dismiss(animated: true, completion: nil)
	}
}

#Preview {
	ActionSheetVC()
}
