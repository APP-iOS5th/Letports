//
//  GatherDeleteTVCell.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import UIKit

class GatherDeleteTVCell: UITableViewCell {
    
    private lazy var TitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .lp_tint
        label.text = "🗑️ 모임 삭제하기"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        self.backgroundColor = .lp_background_white
        contentView.addSubview(TitleLabel)
        NSLayoutConstraint.activate([
            TitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            TitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            TitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            TitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
 
        ])
    }
    
}
