//
//  TableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

class GatheringBoardDetailImagesTVCell: UITableViewCell {
	
	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 30
		layout.minimumInteritemSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.showsHorizontalScrollIndicator = false
		return cv
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
		contentView.backgroundColor = .lp_background_white
		collectionView.backgroundColor = .lp_background_white
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(GatheringBoardDetailImagesCVCell.self,
								forCellWithReuseIdentifier: "GatheringBoardDetailImagesCVCell")
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - Setup
	private func setupUI() {
		self.contentView.addSubview(collectionView)
		contentView.backgroundColor = .red
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -10),
			collectionView.heightAnchor.constraint(equalToConstant: 250)
		])
	}
}

extension GatheringBoardDetailImagesTVCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GatheringBoardDetailImagesCVCell",
															for: indexPath) as? GatheringBoardDetailImagesCVCell else {
			return UICollectionViewCell()
		}
		return cell
	}
}

extension GatheringBoardDetailImagesTVCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let height = collectionView.frame.height
		return CGSize(width: height, height: height)
	}
}
