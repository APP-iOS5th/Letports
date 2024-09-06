//
//  GatheringBoardUploadMemCntTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit

class GatheringUploadMemCntTVCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "모집 인원"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let memStepperView: UIView = {
        let view = UIView()
        view.backgroundColor = .lp_lightGray
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stepperItemStackView: UIStackView = {
        let sv = UIStackView()
        sv.spacing = 6
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .lp_black
        button.addTarget(self, action: #selector(didTapMinusButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .lp_black
        button.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var memCount: Int = 1 {
        didSet {
            delegate?.checkMemberCount(count: memCount)
            countLabel.text = "\(memCount)"
            updateTitleLabel()
        }
    }
    private var memMaxCount: Int = 30
    weak var delegate: GatheringUploadDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .lp_background_white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        [titleLabel, memStepperView].forEach {
            contentView.addSubview($0)
        }
        
        memStepperView.addSubview(stepperItemStackView)
        
        [minusButton, countLabel, plusButton].forEach {
            stepperItemStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            memStepperView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            memStepperView.heightAnchor.constraint(equalToConstant: 36),
            memStepperView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
            memStepperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            memStepperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            memStepperView.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            
            stepperItemStackView.topAnchor.constraint(equalTo: memStepperView.topAnchor, constant: 6),
            stepperItemStackView.leadingAnchor.constraint(equalTo: memStepperView.leadingAnchor, constant: 6),
            stepperItemStackView.trailingAnchor.constraint(equalTo: memStepperView.trailingAnchor, constant: -6),
            stepperItemStackView.bottomAnchor.constraint(equalTo: memStepperView.bottomAnchor, constant: -6),
            
            stepperItemStackView.centerYAnchor.constraint(equalTo: memStepperView.centerYAnchor),
            
            minusButton.widthAnchor.constraint(equalToConstant: 24),
            plusButton.widthAnchor.constraint(equalToConstant: 24),
            countLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
        countLabel.text = "\(memCount)"
    }
    
    func configureCell(nowCount: Int = 1) {
        self.memCount = nowCount
    }
    
    private func updateTitleLabel() {
        let titleText = "모집 인원"
        if memCount >= memMaxCount {
            let fullText = "\(titleText) 최대 모임원은 \(memMaxCount)명 입니다."
            let attributedString = NSMutableAttributedString(string: fullText)
            let range = (fullText as NSString).range(of: "최대 모인원은 \(memMaxCount)명 입니다.")
            
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range)
            attributedString.addAttribute(.font, 
                                          value: UIFont.systemFont(ofSize: 12, weight: .regular), 
                                          range: range)
            
            titleLabel.attributedText = attributedString
        } else {
            titleLabel.text = titleText
        }
    }
    
    
    @objc func didTapMinusButton() {
        if memCount > 1 {
            memCount -= 1
        } else {
            return
        }
    }
    
    @objc func didTapPlusButton() {
        if memCount < memMaxCount {
            memCount += 1
        } else {
            return
        }
    }
}


