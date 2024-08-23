//
//  GatheringDetailBoardTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

protocol GatheringDetailBoardTVCellDelegate: AnyObject {
	func gatheringDetailBoardTVCell(_ cell: GatheringDetailBoardTVCell, didSelectBoardPost boardPost: BoardPost)
}

final class GatheringDetailBoardTVCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
	
	private var tableViewHeightConstraint: NSLayoutConstraint?
	weak var delegate: GatheringDetailBoardTVCellDelegate?
	
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
	
	var boardPosts: [BoardPost] = [] {
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
		])
		
		// 높이 제약 조건 추가
		tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
		tableViewHeightConstraint?.isActive = true
	}
	
	// MARK: - 높이계산
	public func calculateTableViewHeight() -> CGFloat {
		let numberOfRows = boardPosts.count
		let cellHeight: CGFloat = 50 + 12
		return CGFloat(numberOfRows) * cellHeight
	}
	
	private func updateTableViewHeight() {
		let newHeight = calculateTableViewHeight()
		tableViewHeightConstraint?.constant = newHeight
		layoutIfNeeded()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return boardPosts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardTVCell",
													   for: indexPath) as? BoardTVCell else {
			return UITableViewCell()
		}
		let boardPost = boardPosts[indexPath.row]
		cell.configureCell(data: boardPost) { [weak self] in
			guard let self = self else { return }
			self.delegate?.gatheringDetailBoardTVCell(self, didSelectBoardPost: boardPost)
		}
		return cell
	}
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
	return 50 + 12
}


