//
//  GatheringBoardUploadMemCntTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit

class GatheringBoardUploadMemCntTVCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "사전질문"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let memStepperView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor("#D9D9D9", alpha: 1.0)
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
        button.tintColor = .lpBlack
        button.addTarget(self, action: #selector(didTapMinusButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .lpBlack
        button.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var memNowCount: Int = 1 {
        didSet {
            delegate?.checkMemberCount(count: memNowCount)
            countLabel.text = "\(memNowCount)"
        }
    }
    private let memMaxCount: Int = 10
    weak var delegate: GatheringBoardUploadDelegate?
    
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
        countLabel.text = "\(memNowCount)"
    }
    
    
    @objc func didTapMinusButton() {
        if memNowCount > 1 {
            memNowCount -= 1
        } else {
            return
        }
    }
    
    @objc func didTapPlusButton() {
        if memNowCount < memMaxCount {
            memNowCount += 1
        } else {
            return
        }
    }
}

#Preview {
    GatheringBoardUploadVC(viewModel: GatheringBoarduploadVM())
}

