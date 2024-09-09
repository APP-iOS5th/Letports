//
//  SeparatorTVCell.swift
//  Letports
//
//  Created by mosi on 8/29/24.
//


import UIKit

class EmptyStateTVCell: UITableViewCell {
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 20)
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
        contentView.addSubview(emptyStateLabel)
        contentView.backgroundColor = .lp_background_white
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String) {
        emptyStateLabel.text = title
    }
}
