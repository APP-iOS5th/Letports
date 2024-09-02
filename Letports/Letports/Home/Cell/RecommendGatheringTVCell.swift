//
//  RecommendGatheringTVCell.swift
//  Letports
//
//  Created by 홍준범 on 8/27/24.
//

import Foundation
import UIKit

protocol RecommendGatheringListsDelegate: AnyObject {
    func didTapRecommendGathering(gatheringUID: String)
}

class RecommendGatheringTVCell: UITableViewCell {
    
    weak var delegate: RecommendGatheringListsDelegate?
    
    var gatherings: [Gathering] = [] {
        didSet {
            recommendGatheringListsCV.reloadData()
        }
    }
    
    lazy var recommendGatheringListsCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.registersCell(cellClasses: RecommendGatheringListsCVCell.self)
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
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
        recommendGatheringListsCV.backgroundColor = .lp_background_white
        
        contentView.addSubview(recommendGatheringListsCV)
        
        NSLayoutConstraint.activate([
            recommendGatheringListsCV.topAnchor.constraint(equalTo: contentView.topAnchor),
            recommendGatheringListsCV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            recommendGatheringListsCV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recommendGatheringListsCV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func configure(gatherings: [Gathering]) {
        self.gatherings = gatherings
    }
}

extension RecommendGatheringTVCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gatherings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendGatheringListsCVCell", for: indexPath) as? RecommendGatheringListsCVCell else {
            return UICollectionViewCell()
        }
        cell.configure(gathering: gatherings[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapRecommendGathering(gatheringUID: gatherings[indexPath.item].gatheringUid)
    }
}
