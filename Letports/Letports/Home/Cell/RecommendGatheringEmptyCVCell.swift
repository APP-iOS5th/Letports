//
//  RecommendGatheringEmptyCVCell.swift
//  Letports
//
//  Created by 홍준범 on 9/4/24.
//

import Foundation
import UIKit

class RecommendGatheringEmptyCVCell: UICollectionViewCell {
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 생성된 소모임이 없습니다."
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .lpGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            emptyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            emptyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            emptyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
        ])
    }
    
}
