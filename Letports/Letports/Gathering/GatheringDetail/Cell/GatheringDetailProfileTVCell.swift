//
//  GatheringDetailProfileTVCell.swift
//  Letports
//
//  Created by Yachae on 8/14/24.
//

import UIKit

final class GatheringDetailProfileTVCell: UITableViewCell {

	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.showsHorizontalScrollIndicator = false
		return cv
	}()
	
	var profiles: [GatheringDetailVM.Profile] = [] {
		didSet {
			collectionView.reloadData()
		}
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setUpUI()
		collectionView.backgroundColor = .lp_background_white
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(GatheringDetailProfileCVCell.self, 
								forCellWithReuseIdentifier: "GatheringDetailProfileCVCell")
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setUpUI() {
		contentView.addSubview(collectionView)
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
		return profiles.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GatheringDetailProfileCVCell",
															for: indexPath) as? GatheringDetailProfileCVCell else {
			return UICollectionViewCell()
		}
		cell.configure(profile: profiles[indexPath.item])
		return cell
	}
}

extension GatheringDetailProfileTVCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
			
		return CGSize(width: 60, height: 80) // 셀 크기 설정
	}
}
