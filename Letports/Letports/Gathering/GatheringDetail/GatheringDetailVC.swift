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
	
	private let floatingButton: FloatingButton = {
		let button = FloatingButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var tableView: UITableView = {
		let tv = UITableView()
		tv.separatorStyle = .none
		tv.backgroundColor = .lp_background_white
		tv.dataSource = self
		tv.delegate = self
		tv.rsgistersCell(cellClasses: GatheringImageTVCell.self,
						 GatheringTitleTVCell.self,
						 SeperatorLineTVCell.self,
						 GatheringDetailInfoTVCell.self,
						 GatheringDetailProfileTVCell.self,
						 BoardButtonTVCell.self,
						 GatheringDetailBoardTVCell.self)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.rowHeight = UITableView.automaticDimension
		tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
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
		tableView.estimatedRowHeight = 100 // 예상 높이 설정
		tableView.rowHeight = UITableView.automaticDimension
		setupUI()
		setupFloatingButton()
		bindViewModel()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.frame = view.bounds
	}
	
	// MARK: - bindVm
	private func bindViewModel() {
		viewModel.$membershipStatus
			.receive(on: RunLoop.main)
			.sink { [weak self] status in
				self?.updateFloatingButton(for: status)
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
	
	private func updateFloatingButton(for status: MembershipStatus) {
		switch status {
		case .notJoined:
			floatingButton.setTitle("가입하기", for: .normal)
			floatingButton.isHidden = false
		case .pending:
			floatingButton.setTitle("가입대기", for: .normal)
			floatingButton.backgroundColor = .lightGray
			floatingButton.isHidden = false
		case .joined:
			floatingButton.isHidden = true
		}
	}
	
	// MARK: - Setup
	private func setupUI() {
		self.view.backgroundColor = .lpBackgroundWhite
		
		[navigationView, tableView].forEach {
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
		])
	}
	// 플로팅 버튼
	private func setupFloatingButton() {
		view.addSubview(floatingButton)
		// Set constraints for the button
		NSLayoutConstraint.activate([
			floatingButton.widthAnchor.constraint(equalToConstant: 300),
			floatingButton.heightAnchor.constraint(equalToConstant: 50),
			floatingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
	}
}

extension GatheringDetailVC: CustomNavigationDelegate {
	func smallRightButtonDidTap() {
		print("samll")
	}
	
	func sportsSelectButtonDidTap() {
		
	}
	
	func backButtonDidTap() {
		self.dismiss(animated: true)
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
				cell.updateTableViewHeight()
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
			return UITableView.automaticDimension
		case .gatheringProfile:
			return 80
		case .boardButtonType:
			return UITableView.automaticDimension
		case .gatheringBoard:
			return UITableView.automaticDimension
		case .separator:
			return 1
		}
	}
}

extension GatheringDetailVC: BoardButtonTVCellDelegate {
	func updateTableViewData(for boardButtonType: BoardButtonType) {
		viewModel.selectedBoardType = boardButtonType
		tableView.reloadData()
		view.setNeedsLayout()
		view.layoutIfNeeded()
	}
}

#Preview {
	GatheringDetailVC(viewModel: GatheringDetailVM())
}
