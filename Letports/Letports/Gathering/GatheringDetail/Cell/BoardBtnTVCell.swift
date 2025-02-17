//
//  GatheringButtonTVCell.swift
//  Letports
//
//  Created by Yachae on 8/18/24.
//

import UIKit

protocol BoardBtnTVCellDelegate: AnyObject {
    func didSelectBoardType(_ type: PostType)
}

final class BoardBtnTVCell: UITableViewCell {
    
    private let boardButtonTypes: [PostType] = [.all, .noti, .free]
    private var selectedButtonIndex: Int = 0
    private var logoHex: String?
    weak var delegate: BoardBtnTVCellDelegate?
    
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
        collectionView.register(BoardBtnCVCell.self,
                                forCellWithReuseIdentifier: "BoardBtnCVCell")
        // 초기 선택 상태를 delegate에 알림
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didSelectBoardType(.all)
            self?.collectionView.reloadData()
        }
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
    
    func configure(teamColor: String) {
        self.logoHex = teamColor
    }
}

extension BoardBtnTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardButtonTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardBtnCVCell",
                                                            for: indexPath) as? BoardBtnCVCell else {
            return UICollectionViewCell()
        }
        
        let boardButtonType = boardButtonTypes[indexPath.item]
        if let logoHex = logoHex {
            cell.configure(with: boardButtonType, teamColor: logoHex)
        }
        cell.updateButtonUI(isSelected: selectedButtonIndex == indexPath.item)
        
        cell.delegate = self
        return cell
    }
}

extension BoardBtnTVCell: UICollectionViewDelegateFlowLayout {
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
        
        let font = UIFont.lp_Font(.regular, size: 14)
        let width = title.size(withAttributes: [.font: font]).width + 50
        return CGSize(width: width, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

extension BoardBtnTVCell: ButtonStateDelegate {
    func didChangeButtonState(_ button: UIButton, isSelected: Bool) {
        if let indexPath = collectionView.indexPath(for: button.superview?.superview as! UICollectionViewCell) {
            selectedButtonIndex = indexPath.item
            let selectedType = boardButtonTypes[selectedButtonIndex]
            delegate?.didSelectBoardType(selectedType)
        }
        collectionView.reloadData()
    }
}

