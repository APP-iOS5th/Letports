//
//  SportsCell.swift
//  Letports
//
//  Created by John Yun on 8/24/24.
//

import UIKit

class SportsCategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "SportsCategoryCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
		label.font = .lp_Font(.regular, size: 14)
        return label
    }()
    
    private var isCellSelected: Bool = false
    
    func setSelected(_ selected: Bool) {
        isCellSelected = selected
        contentView.backgroundColor = isCellSelected ? UIColor.lpMain : UIColor.clear
        titleLabel.textColor = isCellSelected ? .lpWhite : .lpBlack
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .lp_background_white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .systemGray6
    }
    
    func configure(with category: Sports) {
        titleLabel.text = category.name
    }
}
