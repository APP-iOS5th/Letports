//
//  GatheringButtonTVCell.swift
//  Letports
//
//  Created by Yachae on 8/18/24.
//
import UIKit

protocol BoardButtonTVCellDelegate: AnyObject {
	func updateTableViewData(for boardButtonType: BoardButtonType)
}

final class BoardButtonTVCell: UITableViewCell {
	
	private let boardButtonTypes: [BoardButtonType] = [.all, .noti, .free]
	private var selectedButtonIndex: Int?  // 선택된 버튼 추적
	weak var delegate: BoardButtonTVCellDelegate?
	
	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		layout.minimumInteritemSpacing = 10
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
		
		// 선택 상태에 따라 셀 UI 업데이트
		cell.updateButtonUI(isSelected: selectedButtonIndex == indexPath.item)
		
		cell.delegate = self
		return cell
	}
}

extension BoardButtonTVCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 60, height: 25) // 셀 크기 설정
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10 // 버튼 간의 간격 설정
	}
}

extension BoardButtonTVCell: ButtonStateDelegate {
	func didChangeButtonState(_ button: UIButton, isSelected: Bool) {
		if let indexPath = collectionView.indexPath(for: button.superview?.superview as! UICollectionViewCell) {
			selectedButtonIndex = indexPath.item
			let selectedType = boardButtonTypes[selectedButtonIndex!]
			delegate?.updateTableViewData(for: selectedType)
		}
		collectionView.reloadData()
	}
}


