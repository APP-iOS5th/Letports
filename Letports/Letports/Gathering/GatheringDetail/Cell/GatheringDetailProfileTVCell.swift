//
//  GatheringDetailProfileTVCell.swift
//  Letports
//
//  Created by Yachae on 8/14/24.
//

import UIKit

final class GatheringDetailProfileTVCell: UITableViewCell {
    
    weak var delegate: GatheringDetailDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cv
    }()
    
    var members: [LetportsUser] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        contentView.backgroundColor = .lp_background_white
        collectionView.backgroundColor = .lp_background_white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GatheringDetailProfileCVCell.self,
                                forCellWithReuseIdentifier: "GatheringDetailProfileCVCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        self.contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

extension GatheringDetailProfileTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GatheringDetailProfileCVCell",
                                                            for: indexPath) as? GatheringDetailProfileCVCell else {
            return UICollectionViewCell()
        }
        cell.configure(member: members[indexPath.item])
        cell.delegate = self
        return cell
    }
}

extension GatheringDetailProfileTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 60, height: 70)
    }
}

extension GatheringDetailProfileTVCell: GatheringDetailProfileCVCellDelegate {
    func didTapProfile(member: LetportsUser) {
        delegate?.didTapProfileImage(profile: member)
    }
}
