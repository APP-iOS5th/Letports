//
//  SimpleInfoTVCell.swift
//  Letports
//
//  Created by mosi on 8/23/24.
//
import UIKit

class SimpleInfoTVCell: UITableViewCell {
    
    private lazy var simpleInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "한줄소개"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var simpleInfoTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "한줄소개를 입력해주세요"
        tf.textColor = .lp_black
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    } ()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectionStyle = .none
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .lp_background_white
        [simpleInfoLabel, simpleInfoTextField].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            simpleInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            simpleInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            simpleInfoTextField.topAnchor.constraint(equalTo: simpleInfoLabel.bottomAnchor, constant: 10),
            simpleInfoTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            simpleInfoTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    func configure(with simpleInfo: String) {
        simpleInfoTextField.text = simpleInfo
    }
}
