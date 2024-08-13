//
//  ProfileCV.swift
//  Letports
//
//  Created by Yachae on 8/12/24.
//

import UIKit

class GatheringDetailProfileCV: UICollectionView {
	private let profiles: [Profile]
	
	init(profiles: [Profile]) {
		self.profiles = profiles
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 16 
		layout.minimumInteritemSpacing = 16
		layout.itemSize = CGSize(width: 50, height: 100)
		super.init(frame: .zero, collectionViewLayout: layout)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		translatesAutoresizingMaskIntoConstraints = false
		showsHorizontalScrollIndicator = false
		backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		dataSource = self
		register(GatheringDetailProfileCVCell.self, forCellWithReuseIdentifier: "Cell")
	}
}

extension GatheringDetailProfileCV: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return profiles.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? GatheringDetailProfileCVCell else {
			return UICollectionViewCell()
		}
		cell.configure(profile: profiles[indexPath.item])
		return cell
	}
}


