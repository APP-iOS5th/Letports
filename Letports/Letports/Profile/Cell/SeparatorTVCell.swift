//
//  SeparatorTVCell.swift
//  Letports
//
//  Created by mosi on 8/29/24.
//


import UIKit

class SeparatorTVCell: UITableViewCell {
    
    private lazy var separatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .lp_lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        contentView.addSubview(separatorLabel)
        contentView.backgroundColor = .lp_background_white
        
        NSLayoutConstraint.activate([
            separatorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            separatorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
 
        ])
    }
    
    func configure(withTitle title: String) {
        separatorLabel.text = title
    }
}
