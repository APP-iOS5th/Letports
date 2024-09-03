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
	
	var post: Post? {
		didSet {
			collectionView.reloadData()
			updateCellHeight()
		}
	}
	private func updateCellHeight() {
			if let post = post, !post.imageUrls.isEmpty {
				// 고정된 높이 대신 우선순위를 낮춘 제약 조건 사용
				let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 250)
				heightConstraint.priority = .defaultHigh
				heightConstraint.isActive = true
				collectionView.isHidden = false
			} else {
				collectionView.heightAnchor.constraint(equalToConstant: 0).isActive = true
				collectionView.isHidden = true
			}
			setNeedsLayout()
			layoutIfNeeded()
		}
	
	// MARK: - Setup
	private func setupUI() {
		self.contentView.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
			collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			collectionView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
		])
	}
}

extension GatheringBoardDetailImagesTVCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return post?.imageUrls.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GatheringBoardDetailImagesCVCell",
															for: indexPath) as? GatheringBoardDetailImagesCVCell,
			  let imageUrl = post?.imageUrls[indexPath.item] else {
			return UICollectionViewCell()
		}
		cell.configure(with: imageUrl)
		return cell
	}
}

extension GatheringBoardDetailImagesTVCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let height = collectionView.frame.height - 20
		return CGSize(width: height, height: height)
	}
}
