//
//  GatheringButtonTVCell.swift
//  Letports
//
//  Created by Yachae on 8/18/24.
//

import UIKit

protocol BoardButtonTVCellDelegate: AnyObject {
	func didSelectBoardType(_ type: BoardButtonType)
}

final class BoardButtonTVCell: UITableViewCell {
	
	private let boardButtonTypes: [BoardButtonType] = [.all, .noti, .free]
	private var selectedButtonIndex: Int?
	weak var delegate: BoardButtonTVCellDelegate?
	
	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 10
		layout.minimumLineSpacing = 10
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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
		collectionView.register(BoardButtonCVCell.self,
								forCellWithReuseIdentifier: "BoardButtonCVCell")
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	private func setupUI() {
		contentView.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			collectionView.heightAnchor.constraint(equalToConstant: 30)
		])
	}
}

extension BoardButtonTVCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return boardButtonTypes.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardButtonCVCell",
															for: indexPath) as? BoardButtonCVCell else {
			return UICollectionViewCell()
		}
		
		let boardButtonType = boardButtonTypes[indexPath.item]
		
		cell.configure(with: boardButtonType)
		
		cell.updateButtonUI(isSelected: selectedButtonIndex == indexPath.item)
		
		cell.delegate = self
		return cell
	}
}

extension BoardButtonTVCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let boardButtonType = boardButtonTypes[indexPath.item]
		let title: String
		switch boardButtonType {
		case .all: title = "전체"
		case .noti: title = "공지"
		case .free: title = "자유게시판"
		}
		
		let font = UIFont.systemFont(ofSize: 14)
		let width = title.size(withAttributes: [.font: font]).width + 30
		return CGSize(width: width, height: 25)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}
}

extension BoardButtonTVCell: ButtonStateDelegate {
	func didChangeButtonState(_ button: UIButton, isSelected: Bool) {
		if let indexPath = collectionView.indexPath(for: button.superview?.superview as! UICollectionViewCell) {
			selectedButtonIndex = indexPath.item
			let selectedType = boardButtonTypes[selectedButtonIndex!]
			delegate?.didSelectBoardType(selectedType)
		}
		collectionView.reloadData()
	}
}


