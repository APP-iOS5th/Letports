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
    
    private var user: GatheringMember?
    private var userData: LetportsUser?
    
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
		label.font = .lp_Font(.bold, size: 20)
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plzAnswerLabel: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 14)
        label.textColor = .lp_black
        label.text = "가입질문"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var questionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
		textView.font = .lp_Font(.regular, size: 12)
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
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return textView
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(cancelBtnDidTap), for: .touchUpInside)
		btn.titleLabel?.font = UIFont.lp_Font(.regular, size: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var exitBtn: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        if let image = UIImage(systemName: "xmark")?.resized(size: CGSize(width: 15, height: 15)) {
               btn.setImage(image, for: .normal)
           }
        btn.tintColor = .lp_black
        btn.addTarget(self, action: #selector(exitBtnDidTap), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var expelBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(expelBtnDidTap), for: .touchUpInside)
		btn.titleLabel?.font = UIFont.lp_Font(.regular, size: 15)
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
        [titleLabel, plzAnswerLabel, questionTextView, answerTextView, cancelBtn, expelBtn, exitBtn].forEach {
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
            
            cancelBtn.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 16),
            cancelBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            cancelBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            cancelBtn.widthAnchor.constraint(equalToConstant: 162),
            cancelBtn.heightAnchor.constraint(equalToConstant: 30),
            
            expelBtn.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 16),
            expelBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            expelBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            expelBtn.widthAnchor.constraint(equalToConstant: 162),
            expelBtn.heightAnchor.constraint(equalToConstant: 30),
            
            exitBtn.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 5),
            exitBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
    }
    
    @objc private func exitBtnDidTap() {
        if pendingdelegate != nil {
            pendingdelegate?.cancelAction(self)
        }
    }
    
    @objc private func cancelBtnDidTap() {
        guard let uid = user?.userUID else { return }
        guard let nickname = userData?.nickname else { return }
        if joindelegate != nil {
            joindelegate?.cancelAction(self)
        }
        if pendingdelegate != nil {
            pendingdelegate?.denyJoinGathering(self,userUid: uid, nickName: nickname)
        }
    }
    
    @objc private func expelBtnDidTap() {
        guard let uid = user?.userUID else { return }
        guard let nickname = userData?.nickname else { return }
        if joindelegate != nil {
            joindelegate?.expelGathering(self,userUid: uid, nickName: nickname)
        }
        if pendingdelegate != nil {
            pendingdelegate?.apporveJoinGathering(self,userUid: uid, nickName: nickname)
        }
    }
    
    func configure(user: GatheringMember, gathering: Gathering, userData: LetportsUser) {
        self.userData = userData
        self.user = user
        if joindelegate != nil {
            cancelBtn.setTitle("취소", for: .normal)
            cancelBtn.backgroundColor = UIColor(named: "lp_gray")
            expelBtn.setTitle("추방", for: .normal)
            expelBtn.backgroundColor = UIColor(named: "lp_tint")
        }
        
        if pendingdelegate != nil {
            exitBtn.isHidden = false
            cancelBtn.setTitle("거절", for: .normal)
            cancelBtn.backgroundColor = UIColor(named: "lp_tint")
            expelBtn.setTitle("승인", for: .normal)
            expelBtn.backgroundColor = UIColor(named: "lp_main")
        }
        
        titleLabel.text = gathering.gatherName
        questionTextView.text = gathering.gatherQuestion
        answerTextView.text = user.answer
    }
}
