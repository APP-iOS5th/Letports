//
//  RecommendGatheringListsCVCell.swift
//  Letports
//
//  Created by 홍준범 on 8/27/24.
//

import Foundation
import UIKit

class RecommendGatheringListsCVCell: UICollectionViewCell {
    
    lazy var gatheringImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    lazy var gatheringName: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .lp_white
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
        self.contentView.addSubview(gatheringImage)
        gatheringImage.addSubview(gatheringName)
        
        NSLayoutConstraint.activate([
            gatheringImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            gatheringImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gatheringImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gatheringImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gatheringName.leadingAnchor.constraint(equalTo: gatheringImage.leadingAnchor, constant: 10),
            gatheringName.bottomAnchor.constraint(equalTo: gatheringImage.bottomAnchor, constant: -5),
            gatheringName.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let gatheringTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGatheringTap))
        gatheringImage.addGestureRecognizer(gatheringTapGesture)
        gatheringImage.isUserInteractionEnabled = true
    }
    
    @objc func handleGatheringTap() {
        
    }
    
    func configure(gathering: Gathering) {
        if let url = URL(string: gathering.gatherImage) {
            gatheringImage.kf.setImage(with: url)
        }
        gatheringName.text = gathering.gatherName
    }
}
