//
//  GatheringDetailBoardTV.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

class GatheringDetailBoardTV: UITableView {
	
	private var board: [Board]
	
	init(board: [Board]) {
		self.board = board
		super.init(frame: .zero, style: .plain)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		dataSource = self
		delegate = self
		register(BoardTVCell.self, forCellReuseIdentifier: "BoardTVC")
	}
}

extension GatheringDetailBoardTV: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return board.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardTVC", for: indexPath) as? BoardTVCell else {
			return UITableViewCell()
		}
		
		cell.configure(board: allBoard[indexPath.item])
		return cell
	}
}

extension GatheringDetailBoardTV: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 셀 선택 시 동작
		tableView.deselectRow(at: indexPath, animated: true)
		print("셀이 눌렸습니다")
	}
}
