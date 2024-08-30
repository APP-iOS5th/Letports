//
//  JoiningUser.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//

import UIKit


class ManageUserView: UIView {
    
    weak var joindelegate: ManageViewJoinDelegate?
    weak var pendingdelegate: ManageViewPendingDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .lp_background_white
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plzAnswerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lp_black
        label.text = "가입질문"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var questionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 12)
        textView.backgroundColor = .lp_background_white
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var answerTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.clipsToBounds = true
        textView.isEditable = false
        textView.layer.cornerRadius = 20
        textView.backgroundColor = .lp_white
        textView.textColor = .lp_black
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var cancelButton: UIButton = {
        let btn = UIButton()
        
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var expelButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(expelButtonTapped), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        self.addSubview(containerView)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.translatesAutoresizingMaskIntoConstraints = false
        [titleLabel, plzAnswerLabel, questionTextView, answerTextView, cancelButton, expelButton].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 361),
            containerView.heightAnchor.constraint(equalToConstant: 468),
            
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            plzAnswerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            plzAnswerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            questionTextView.topAnchor.constraint(equalTo: plzAnswerLabel.bottomAnchor, constant: 5),
            questionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            questionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            questionTextView.heightAnchor.constraint(equalToConstant: 72),
            
            answerTextView.topAnchor.constraint(equalTo: questionTextView.bottomAnchor, constant: 10),
            answerTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            answerTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            answerTextView.heightAnchor.constraint(equalToConstant: 252),
            
            cancelButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 162),
            cancelButton.heightAnchor.constraint(equalToConstant: 30),
            
            expelButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 16),
            expelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            expelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            expelButton.widthAnchor.constraint(equalToConstant: 162),
            expelButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    @objc private func cancelButtonTapped() {
        if joindelegate != nil {
            joindelegate?.expelGathering()
        }
        if pendingdelegate != nil {
            pendingdelegate?.denyJoinGathering()
        }
    }
    
    @objc private func expelButtonTapped() {
        if joindelegate != nil {
            joindelegate?.expelGathering()
        }
        if pendingdelegate != nil {
            pendingdelegate?.apporveJoinGathering()
        }
    }
    
    func configure(user: GatheringMember, gathering: Gathering) {
        if joindelegate != nil {
            cancelButton.setTitle("취소", for: .normal)
            cancelButton.backgroundColor = UIColor(named: "lp_gray")
            expelButton.setTitle("추방", for: .normal)
            expelButton.backgroundColor = UIColor(named: "lp_tint")
        }
        if pendingdelegate != nil {
            cancelButton.setTitle("거절", for: .normal)
            cancelButton.backgroundColor = UIColor(named: "lp_tint")
            expelButton.setTitle("승인", for: .normal)
            expelButton.backgroundColor = UIColor(named: "lp_main")
        }
        titleLabel.text = gathering.gatherName
        questionTextView.text = gathering.gatherQuestion
        answerTextView.text = user.answer
    }
}
