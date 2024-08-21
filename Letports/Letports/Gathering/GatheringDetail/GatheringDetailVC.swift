//
//  GatheringDetailVC.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit
import Combine

final class GatheringDetailVC: UIViewController {
	private lazy var navigationView: CustomNavigationView = {
		let cnv = CustomNavigationView(isLargeNavi: .small,
									   screenType: .smallGathering(gatheringName: "수호단", btnName: .gear))
		
		cnv.delegate = self
		cnv.backgroundColor = .lp_background_white
		cnv.translatesAutoresizingMaskIntoConstraints = false
		return cnv
	}()
	
	private let joinButton: JoinButton = {
		let bt = JoinButton()
		bt.translatesAutoresizingMaskIntoConstraints = false
		return bt
	}()
	
	private lazy var postButton: PostButton = {
		let bt = PostButton()
		bt.translatesAutoresizingMaskIntoConstraints = false
		return bt
	}()
	
	private lazy var tableView: UITableView = {
		let tv = UITableView()
		tv.separatorStyle = .none
		tv.backgroundColor = .lp_background_white
		tv.dataSource = self
		tv.delegate = self
		tv.registersCell(cellClasses: GatheringImageTVCell.self,
						 GatheringTitleTVCell.self,
						 SeperatorLineTVCell.self,
						 GatheringDetailInfoTVCell.self,
						 currentMemTVCell.self,
						 GatheringDetailProfileTVCell.self,
						 BoardButtonTVCell.self,
						 GatheringDetailBoardTVCell.self)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.rowHeight = UITableView.automaticDimension
		return tv
	}()
	
	private var viewModel: GatheringDetailVM
	private var cancellables: Set<AnyCancellable> = []
	
	init(viewModel: GatheringDetailVM) {
		self.viewModel = GatheringDetailVM()
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
	
	// MARK: - bindVm
	private func bindViewModel() {
		viewModel.$membershipStatus
			.receive(on: RunLoop.main)
			.sink { [weak self] status in
				self?.updateJoinButton(for: status)
				self?.updateFloatingActionButton(for: status)
			}
			.store(in: &cancellables)
		
		viewModel.$isMaster
			.receive(on: RunLoop.main)
			.sink { [weak self] isMaster in
				self?.postButton.isMaster = isMaster
			}
			.store(in: &cancellables)
		
		viewModel.$selectedBoardType
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
				self?.view.setNeedsLayout()
				self?.view.layoutIfNeeded()
			}
			.store(in: &cancellables)
	}
	
	private func updateJoinButton(for status: MembershipStatus) {
		switch status {
		case .notJoined:
			joinButton.setTitle("가입하기", for: .normal)
			joinButton.isHidden = false
		case .pending:
			joinButton.setTitle("가입대기", for: .normal)
			joinButton.backgroundColor = .lightGray
			joinButton.isHidden = false
		case .joined:
			joinButton.isHidden = true
		}
	}
	
	private func updateFloatingActionButton(for status: MembershipStatus) {
		switch status {
		case .notJoined, .pending:
			postButton.setVisible(false)
		case .joined:
			postButton.setVisible(true)
		}
	}
	
	// MARK: - Setup
	private func setupUI() {
		self.view.backgroundColor = .lp_background_white
		
		[navigationView, tableView, joinButton, postButton].forEach {
			self.view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			
			tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			joinButton.widthAnchor.constraint(equalToConstant: 300),
			joinButton.heightAnchor.constraint(equalToConstant: 50),
			joinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			joinButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			
			postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			postButton.widthAnchor.constraint(equalToConstant: 60),
			postButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}
}

// MARK: - extension

extension GatheringDetailVC: CustomNavigationDelegate {
	func smallRightButtonDidTap() {
		print("samll")
	}
	
	func sportsSelectButtonDidTap() {
	}
	
	func backButtonDidTap() {
		
	}
}

extension GatheringDetailVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.viewModel.getDetailCellTypes()[indexPath.row] {
		case .gatheringImage:
			if let cell: GatheringImageTVCell = tableView.loadCell(indexPath: indexPath) {
				if let data = viewModel.GatheringHeaders.first(where: { $0.gatheringName == "수호단" }) {
					cell.configureCell(data: data)
				}
				return cell
			}
		case .gatheringTitle:
			if let cell: GatheringTitleTVCell  = tableView.loadCell(indexPath: indexPath) {
				if let data = viewModel.GatheringHeaders.first(where: { $0.gatheringName == "수호단" }) {
					cell.configureCell(data: data, isMaster: viewModel.isMaster)
				}
				return cell
			}
		case .separator:
			if let cell: SeperatorLineTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.configureCell(height: 1)
				return cell
			}
		case .gatheringInfo:
			if let cell: GatheringDetailInfoTVCell = tableView.loadCell(indexPath: indexPath) {
				return cell
			}
		case .gatheringProfile:
			if let cell: GatheringDetailProfileTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.profiles = viewModel.profiles
				return cell
			}
		case .boardButtonType:
			if let cell: BoardButtonTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.delegate = self
				return cell
			}
		case .gatheringBoard:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "GatheringDetailBoardTVCell", for: indexPath) as? GatheringDetailBoardTVCell {
				cell.board = viewModel.filteredBoardData
				return cell
			}
		case .currentMemLabel:
			if let cell: currentMemTVCell = tableView.loadCell(indexPath: indexPath) {
				return cell
			}
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModel.getDetailCellCount()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellType = self.viewModel.getDetailCellTypes()[indexPath.row]
		switch cellType {
		case .gatheringImage:
			return 200
		case .gatheringTitle:
			return UITableView.automaticDimension
		case .gatheringInfo:
			if let cell = tableView.cellForRow(at: indexPath) as? GatheringDetailInfoTVCell {
				return cell.getHeight()
			}
			return UITableView.automaticDimension
		case .gatheringProfile:
			return 80
		case .boardButtonType:
			return UITableView.automaticDimension
		case .gatheringBoard:
			return viewModel.calculateBoardHeight()
		case .separator:
			return 1
		case .currentMemLabel:
			return UITableView.automaticDimension
		}
	}
}

extension GatheringDetailVC: BoardButtonTVCellDelegate {
	func didSelectBoardType(_ type: BoardButtonType) {
		viewModel.selectedBoardType = type
		tableView.reloadData()
	}
}

#Preview {
	GatheringDetailVC(viewModel: GatheringDetailVM())
}
