//
//  RecommendGatheringListsCVCell.swift
//  Letports
//
//  Created by 홍준범 on 8/27/24.
//

import Foundation
import UIKit

class RecommendGatheringListsCVCell: UICollectionViewCell {
    
    lazy var gatheringNameBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var gatheringImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    lazy var gatheringName: UILabel = {
        let label = UILabel()
        label.font = .lp_Font(.regular, size: 22)
        label.textColor = .lp_white
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
        self.contentView.addSubview(gatheringImage)
        gatheringImage.addSubview(gatheringNameBackgroundView)
        gatheringNameBackgroundView.addSubview(gatheringName)
        
        NSLayoutConstraint.activate([
            gatheringImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            gatheringImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gatheringImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gatheringImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gatheringNameBackgroundView.leadingAnchor.constraint(equalTo: gatheringImage.leadingAnchor),
            gatheringNameBackgroundView.trailingAnchor.constraint(equalTo: gatheringImage.trailingAnchor),
            gatheringNameBackgroundView.bottomAnchor.constraint(equalTo: gatheringImage.bottomAnchor),
            gatheringNameBackgroundView.heightAnchor.constraint(equalToConstant: 40),
            
            gatheringName.topAnchor.constraint(equalTo: gatheringNameBackgroundView.topAnchor),
            gatheringName.bottomAnchor.constraint(equalTo: gatheringNameBackgroundView.bottomAnchor),
            gatheringName.leadingAnchor.constraint(equalTo: gatheringNameBackgroundView.leadingAnchor, constant: 10),
            gatheringName.trailingAnchor.constraint(equalTo: gatheringNameBackgroundView.trailingAnchor, constant: -10),
        ])
    }
    
    func configure(gathering: Gathering) {
        if let url = URL(string: gathering.gatherImage) {
            gatheringImage.kf.setImage(with: url)
        }
        gatheringName.text = gathering.gatherName
    }
}
