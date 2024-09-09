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
        label.text = "아직 생성된\n소모임이 없습니다."
        label.numberOfLines = 0
		label.font = UIFont.lp_Font(.bold, size: 30)
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
            emptyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
}
