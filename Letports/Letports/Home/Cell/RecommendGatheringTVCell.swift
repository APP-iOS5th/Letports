//
//  RecommendGatheringTVCell.swift
//  Letports
//
//  Created by 홍준범 on 8/27/24.
//

import Foundation
import UIKit

protocol RecommendGatheringListsDelegate: AnyObject {
    func didTapRecommendGathering()
}

class RecommendGatheringTVCell: UITableViewCell {
    
    weak var delegate: RecommendGatheringListsDelegate?
    
    var gatherings: [Gathering] = []
    
    lazy var recommendGatheringListsCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
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
        
        contentView.addSubview(recommendGatheringListsCV)
        
        NSLayoutConstraint.activate([
            recommendGatheringListsCV.topAnchor.constraint(equalTo: contentView.topAnchor),
            recommendGatheringListsCV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recommendGatheringListsCV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recommendGatheringListsCV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    //소모임 탭 액션
    @objc func handleGatheringTap() {
        delegate?.didTapRecommendGathering()
    }
}

extension RecommendGatheringTVCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gatherings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendGatheringCVCell", for: indexPath) as? RecommendGatheringListsCVCell else {
            return UICollectionViewCell()
        }
        cell.configure(gathering: gatherings[indexPath.item])
        print("배고프다 \(gatherings[indexPath.item])")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
