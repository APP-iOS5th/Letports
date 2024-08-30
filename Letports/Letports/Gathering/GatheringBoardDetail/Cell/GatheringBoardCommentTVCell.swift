//
//  GatheringBoardDetailCommertTVCell.swift
//  Letports
//
//  Created by Yachae on 8/20/24.
//

import UIKit

//class GatheringBoardCommentTVCell: UITableViewCell {
//	
//	private var tableViewHeightConstraint: NSLayoutConstraint?
//    private var viewModel: GatheringBoardDetailVM?
//    
//	private lazy var tableView: UITableView = {
//		let tv = UITableView()
//		tv.translatesAutoresizingMaskIntoConstraints = false
//		tv.separatorStyle = .none
//		tv.backgroundColor = .clear
//		tv.allowsSelection = false
//		tv.isScrollEnabled = false
//		tv.backgroundColor = .lp_background_white
//		tv.dataSource = self
//		tv.delegate = self
//        tv.rowHeight = UITableView.automaticDimension
//        tv.estimatedRowHeight = 80
//		tv.register(CommentTVCell.self, forCellReuseIdentifier: "CommentTVCell")
//		return tv
//	}()
//	
//	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//		super.init(style: style, reuseIdentifier: reuseIdentifier)
//		self.selectionStyle = .none
//		setupUI()
//	}
//	
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//	
//	var board: [Comment] = [] {
//		didSet {
//			tableView.reloadData()
//			updateTableViewHeight()
//            self.layoutIfNeeded()
//		}
//	}
//	
//	// MARK: - Setup
//	private func setupUI() {
//		self.contentView.backgroundColor = .lp_background_white
//		self.contentView.addSubview(tableView)
//		NSLayoutConstraint.activate([
//			tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//			tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//			tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
//			tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//		])
//		
//		// 높이 제약 조건 추가
//		tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
//		tableViewHeightConstraint?.isActive = true
//	}
//	
//	// MARK: - 높이계산
//	public func calculateTableViewHeight() -> CGFloat {
//		let numberOfRows = board.count
//		let cellHeight: CGFloat = 80 + 10
//		return CGFloat(numberOfRows) * cellHeight
//	}
//	
//	private func updateTableViewHeight() {
//		let newHeight = calculateTableViewHeight()
//		tableViewHeightConstraint?.constant = newHeight
//		layoutIfNeeded()
//	}
//	
//	func updateCommentList(comments: [Comment], viewModel: GatheringBoardDetailVM) {
//		self.board = comments
//        self.viewModel = viewModel
//	}
//}
//
//// MARK: -  extension
//
//extension GatheringBoardCommentTVCell: UITableViewDataSource {
//	
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return board.count
//	}
//	
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTVCell",
//													   for: indexPath) as? CommentTVCell,
//              let viewModel = self.viewModel else {
//			return UITableViewCell()
//		}
//		let comment = board[indexPath.row]
////		cell.configureCell(data: comment, viewModel: viewModel)
//		return cell
//	}
//}
//
//extension GatheringBoardCommentTVCell: UITableViewDelegate {
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//	}
//}
