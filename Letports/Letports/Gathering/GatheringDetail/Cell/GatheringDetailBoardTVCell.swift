//
//  GatheringDetailBoardTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

final class GatheringDetailBoardTVCell: UITableViewCell {
	
	private var tableViewHeightConstraint: NSLayoutConstraint?
	weak var delegate: GatheringDetailDelegate?
	var viewModel: GatheringDetailVM?
	
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
	
	private lazy var emptyStateLabel: UILabel = {
		let label = UILabel()
		label.text = "글이 없어요..."
		label.textAlignment = .center
		label.textColor = .gray
		label.font = UIFont.systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var board: [Post] = [] {
		didSet {
			tableView.reloadData()
			updateTableViewHeight()
			updateEmptyState()
		}
	}
	
	var membershipStatus: MembershipStatus = .notJoined {
		didSet {
			tableView.reloadData()
		}
	}
	
	// MARK: - Setup
	private func setupUI() {
		self.contentView.addSubview(tableView)
		self.contentView.addSubview(emptyStateLabel)
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
			
			emptyStateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			emptyStateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
		])
		
		// 높이 제약 조건 추가
		tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
		tableViewHeightConstraint?.isActive = true
	}
	
	// MARK: - 높이계산
	private func updateTableViewHeight() {
		guard let viewModel = viewModel else { return }
		let newHeight = viewModel.calculateBoardHeight()
		tableViewHeightConstraint?.constant = newHeight
		layoutIfNeeded()
	}
	
	private func updateEmptyState() {
		emptyStateLabel.isHidden = !board.isEmpty
	}
}


// MARK: - UITableViewDataSource
extension GatheringDetailBoardTVCell: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return board.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardTVCell",
													   for: indexPath) as? BoardTVCell else {
			return UITableViewCell()
		}
		let isActive = membershipStatus == .joined
		let post = board[indexPath.row]
		cell.configureCell(data: board[indexPath.row], isActive: isActive, post: post)
		cell.delegate = self
		return cell
	}
}

// MARK: - UITableViewDelegate
extension GatheringDetailBoardTVCell: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70 + 12
	}
}

// MARK: - BoardTVCellDelegate
extension GatheringDetailBoardTVCell: BoardTVCellDelegate {
	func didTapCell(boardPost: Post) {
		delegate?.didTapCell(boardPost: boardPost)
	}
}
