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
    
    var board: [Post] = [] {
        didSet {
            tableView.reloadData()
            updateTableViewHeight()
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
        let numberOfRows = board.count
        let cellHeight: CGFloat = 70 + 12
        return CGFloat(numberOfRows) * cellHeight
    }
    
    private func updateTableViewHeight() {
        let newHeight = calculateTableViewHeight()
        tableViewHeightConstraint?.constant = newHeight
        layoutIfNeeded()
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
        cell.configureCell(data: board[indexPath.row], isActive: isActive)
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
