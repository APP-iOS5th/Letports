//
//  GatheringDetailBoardTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

final class GatheringDetailBoardTVCell: UITableViewCell {
	
	private let tableView: UITableView = {
		let tv = UITableView()
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.separatorStyle = .none
		tv.backgroundColor = .clear
		tv.isScrollEnabled = false
		tv.backgroundColor = .lp_background_white
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
	
	// MARK: - Setup
	private func setupUI() {
		contentView.addSubview(tableView)
		contentView.backgroundColor = .red
		tableView.dataSource = self
		tableView.delegate = self
		
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
		return 5
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardTVCell",
													   for: indexPath) as? BoardTVCell else {
			return UITableViewCell()
		}
		return cell
	}
}

extension GatheringDetailBoardTVCell: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44 + 12
	}
	
	func updateTableViewHeight() {
		// 내부 테이블뷰의 전체 높이를 계산하여 외부 셀의 높이를 설정
		let totalHeight = CGFloat(tableView.numberOfRows(inSection: 0)) * 44 // 각 셀의 높이 * 셀의 수
		// 외부 셀의 높이를 내부 테이블뷰의 전체 높이로 설정
		self.contentView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
	}
}


