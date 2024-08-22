//
//  JoinScreenUIView.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import UIKit

protocol SignupVCDelegate: AnyObject {
	func signupVCDidTapApplyBtn(_ viewController: SignupVC)
	func signupVCDidTapCancelBtn(_ viewController: SignupVC)
}

class SignupVC: UIViewController {
	
	weak var delegate: SignupVCDelegate?
	
	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .lp_background_white
		view.layer.cornerRadius = 20
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "FC서울 - 수호신"
		label.font = .systemFont(ofSize: 18, weight: .bold)
		label.textAlignment = .center
		return label
	}()
	
	private let plzAnswerLabel: UILabel = {
		let lb = UILabel()
		lb.backgroundColor = .lp_background_white
		lb.font = .systemFont(ofSize: 14)
		lb.text = "가입 질문에 답해주세요"
		return lb
	}()
	
	private let questionTextView: UITextView = {
		let textView = UITextView()
		textView.isEditable = false
		textView.font = .systemFont(ofSize: 14)
		textView.backgroundColor = .lp_background_white
		textView.text = """
  1. FC서울 구단가 외우시나요?
  외우신다면 가사 일부를 적어주세요
  외우지 않으셔도 괜찮아요!
  2. FC서울에 대해서 알고 있나요?
  - 간단히 어시스트 작성해주세요!
  3. 가입을 하고자 한 이유가 있을까요?
  """
		return textView
	}()
	
	private let answerTextView: UITextView = {
		let textView = UITextView()
		textView.font = .systemFont(ofSize: 14)
		textView.layer.borderWidth = 1
		textView.clipsToBounds = true
		textView.layer.cornerRadius = 20
		textView.layer.borderColor = UIColor.lightGray.cgColor
		textView.textColor = .lightGray
		return textView
	}()
	
	private let placeholderLabel: UILabel = {
		let label = UILabel()
		label.text = "답변을 작성해주세요."
		label.font = .systemFont(ofSize: 14)
		label.textColor = .lightGray
		return label
	}()
	
	private let cancelBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("취소", for: .normal)
		btn.setTitleColor(.systemRed, for: .normal)
		btn.addTarget(SignupVC.self, action: #selector(cancelButtonTapped), for: .touchUpInside)
		return btn
	}()
	
	private let applyBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.setTitle("가입 신청", for: .normal)
		btn.setTitleColor(.systemBlue, for: .normal)
		btn.addTarget(SignupVC.self, action: #selector(applyButtonTapped), for: .touchUpInside)
		return btn
	}()
	
	private let btnSV: UIStackView = {
		let sv = UIStackView()
		return sv
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		answerTextView.delegate = self
		modalPresentationStyle = .overFullScreen
	}
	
	// MARK: -  setupUI
	
	private func setupUI() {
		view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		
		view.addSubview(containerView)
		containerView.addSubview(titleLabel)
		containerView.addSubview(questionTextView)
		containerView.addSubview(plzAnswerLabel)
		containerView.addSubview(answerTextView)
		answerTextView.addSubview(placeholderLabel)
		containerView.addSubview(cancelBtn)
		containerView.addSubview(applyBtn)
		
		[containerView, titleLabel, questionTextView, plzAnswerLabel, answerTextView, placeholderLabel, cancelBtn, applyBtn].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		
		NSLayoutConstraint.activate([
			containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
			containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
			
			titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
			
			plzAnswerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
			plzAnswerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			
			questionTextView.topAnchor.constraint(equalTo: plzAnswerLabel.bottomAnchor, constant: 20),
			questionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
			questionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
			questionTextView.heightAnchor.constraint(equalToConstant: 150),
			
			placeholderLabel.topAnchor.constraint(equalTo: answerTextView.topAnchor, constant: 16),
			placeholderLabel.leadingAnchor.constraint(equalTo: answerTextView.leadingAnchor, constant: 16),
			placeholderLabel.trailingAnchor.constraint(equalTo: answerTextView.trailingAnchor, constant: -4),
			
			answerTextView.topAnchor.constraint(equalTo: questionTextView.bottomAnchor, constant: 20),
			answerTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
			answerTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
			answerTextView.heightAnchor.constraint(equalToConstant: 200),
			
			cancelBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
			cancelBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
			
			applyBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
			applyBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
		])
	}
	
	@objc private func applyButtonTapped() {
		print("Apply button tapped in SignupVC")
		delegate?.signupVCDidTapApplyBtn(self)
	}

	@objc private func cancelButtonTapped() {
		print("Cancel button tapped in SignupVC")
		delegate?.signupVCDidTapCancelBtn(self)
	}
}

// MARK: - extension

extension SignupVC: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		placeholderLabel.isHidden = !textView.text.isEmpty
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == .lightGray {
			textView.text = nil
			textView.textColor = .black
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "답변을 작성해주세요."
			textView.textColor = .lightGray
		}
	}
}

#Preview {
	SignupVC()
}
