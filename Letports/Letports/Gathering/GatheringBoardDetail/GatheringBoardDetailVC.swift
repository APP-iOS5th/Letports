//
//  GatheringBoardDetailVC.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit
import Combine

final class GatheringBoardDetailVC: UIViewController {
	
	private lazy var navigationView: CustomNavigationView = {
		let cnv = CustomNavigationView(isLargeNavi: .small,
									   screenType: .smallGathering(gatheringName: "자유게시판", btnName: .gear))
		
		cnv.delegate = self
		cnv.backgroundColor = .lp_background_white
		cnv.translatesAutoresizingMaskIntoConstraints = false
		return cnv
	}()
	
	private lazy var tableView: UITableView = {
		let tv = UITableView()
		tv.separatorStyle = .none
		tv.backgroundColor = .lp_background_white
		tv.dataSource = self
		tv.delegate = self
		tv.registersCell(cellClasses: GatheringBoardDetailProfileTVCell.self,
						 GatheringBoardDetailContentTVCell.self,
						 SeperatorLineTVCell.self,
						 GatheringBoardDetailImagesTVCell.self,
						 CommentHeaderLabelTVCell.self,
						 GatheringBoardCommentTVCell.self)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.rowHeight = UITableView.automaticDimension
		return tv
	}()
	
	private let commentInputView: CommentInputView = {
		let view = CommentInputView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private var viewModel: GatheringBoardDetailVM
	private var cancellables = Set<AnyCancellable>()
	
	init(viewModel: GatheringBoardDetailVM) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	private func bindViewModel() {
		viewModel.$boardPost
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)
	}
	
	
	// MARK: - setupUI()
	private func setupUI() {
		self.view.backgroundColor = .lp_background_white
		
		[navigationView, tableView, commentInputView].forEach {
			self.view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			
			tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: commentInputView.topAnchor),
			
			commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			commentInputView.heightAnchor.constraint(equalToConstant: 70)
		])
	}
}

extension GatheringBoardDetailVC: CustomNavigationDelegate {
	func smallRightBtnDidTap() {
		print("samll")
	}
	func sportsSelectBtnDidTap() {
		
	}
	func backBtnDidTap() {
		viewModel.backButtonTapped()
	}
}

extension GatheringBoardDetailVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.viewModel.getBoardDetailCellTypes()[indexPath.row] {
		case .boardProfileTitle:
			if let cell: GatheringBoardDetailProfileTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.configure(with: viewModel.postAuthor)
				return cell
			}
		case .boardContents:
			if let cell: GatheringBoardDetailContentTVCell  = tableView.loadCell(indexPath: indexPath) {
				if let post = viewModel.boardPost {
					cell.configure(with: post)
				}
				return cell
			}
		case .separator:
			if let cell: SeperatorLineTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.configureCell(height: 1)
				return cell
			}
		case .images:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatheringBoardDetailImagesTVCell",
														   for: indexPath) as? GatheringBoardDetailImagesTVCell else {
				return UITableViewCell()
			}
			cell.post = viewModel.boardPost
			return cell
			
		case .commentHeaderLabel:
			if let cell: CommentHeaderLabelTVCell = tableView.loadCell(indexPath: indexPath) {
				return cell
			}
		case .comment:
			if let cell: GatheringBoardCommentTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.updateCommentList(viewModel.comment)
				return cell
			}
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModel.getBoardDetailCount()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellType = self.viewModel.getBoardDetailCellTypes()[indexPath.row]
		switch cellType {
		case .boardProfileTitle:
			return UITableView.automaticDimension
		case .boardContents:
			return UITableView.automaticDimension
		case .separator:
			return 1
		case .images:
			return UITableView.automaticDimension
		case .commentHeaderLabel:
			return UITableView.automaticDimension
		case .comment:
			if let cell = tableView.cellForRow(at: indexPath) as? GatheringBoardCommentTVCell {
				return cell.calculateTableViewHeight()
			}
			return UITableView.automaticDimension
		}
	}
}
