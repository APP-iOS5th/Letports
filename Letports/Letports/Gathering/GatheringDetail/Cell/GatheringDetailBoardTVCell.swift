//
//  GatheringDetailBoardTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

final class GatheringDetailBoardTVCell: UITableViewCell {
	
	private lazy var tableView: UITableView = {
		let tv = UITableView()
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.separatorStyle = .none
		tv.backgroundColor = .clear
		tv.isScrollEnabled = false
		tv.backgroundColor = .lp_background_white
		tv.dataSource = self
		tv.delegate = self
		tv.register(BoardTVCell.self, forCellReuseIdentifier: "BoardTVCell")
		return tv
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var board: [GatheringDetailVM.BoardData] = [] {
			didSet {
				tableView.reloadData()
				updateTableViewHeight()
			}
		}
	
	// MARK: - Setup
	private func setupUI() {
		self.contentView.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	func calculateTableViewHeight() -> CGFloat {
		tableView.layoutIfNeeded()
		return tableView.contentSize.height
	}
}

extension GatheringDetailBoardTVCell: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return board.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardTVCell",
													   for: indexPath) as? BoardTVCell else {
			return UITableViewCell()
		}
		cell.configureCell(data: board[indexPath.row])
		return cell
	}
}

extension GatheringDetailBoardTVCell: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44 + 12
	}
	
	func updateTableViewHeight() {
		let totalHeight = calculateTableViewHeight()
		// 높이 제약 조건을 업데이트하거나 새로 만듭니다.
		if let constraint = contentView.constraints.first(where: { $0.firstAttribute == .height }) {
			constraint.constant = totalHeight
		} else {
			contentView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
		}
		layoutIfNeeded()
		
		// 부모 테이블 뷰에 높이 변경을 알립니다.
		if let tableView = superview as? UITableView {
			tableView.beginUpdates()
			tableView.endUpdates()
		}
	}
}


