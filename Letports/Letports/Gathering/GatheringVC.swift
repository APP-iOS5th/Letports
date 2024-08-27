//
//  GatheringVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit
import Combine
import Kingfisher

class GatheringVC: UIViewController {
	
	private var viewModel: GatheringVM
	private var cancellables: Set<AnyCancellable> = []
	weak var coordinator: GatheringCoordinator?
	
	
	init(viewModel: GatheringVM) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private(set) lazy var navigationView: CustomNavigationView = {
		let cnv = CustomNavigationView(isLargeNavi: .large,
									   screenType: .largeGathering)
		
		cnv.delegate = self
		cnv.backgroundColor = .lp_background_white
		cnv.translatesAutoresizingMaskIntoConstraints = false
		return cnv
	}()
	
	private(set) lazy var tableView: UITableView = {
		let tv = UITableView()
		tv.delegate = self
		tv.dataSource = self
		tv.separatorStyle = .none
		tv.registersCell(cellClasses: SectionTVCell.self, GatheringTVCell.self)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.backgroundColor = .lp_background_white
		
		return tv
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	private func setupUI() {
		view.backgroundColor = .lpBackgroundWhite
		[navigationView, tableView].forEach {
			self.view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	private func bindViewModel() {
		viewModel.$recommendGatherings
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)
		
		viewModel.$gatheringLists
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)
	}
}

extension GatheringVC: CustomNavigationDelegate {
	func sportsSelectButtonDidTap() {
		print("TeamChangeView")
	}
}

extension GatheringVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.getCellCount()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch viewModel.getCellTypes()[indexPath.row] {
		case .recommendGatherings, .gatheringLists: viewModel.pushGatheringDetailController()
		default:
			break
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellType = self.viewModel.getCellTypes()[indexPath.row]
		switch cellType {
		case .recommendGatheringHeader:
			return 80.0
		case .recommendGatherings:
			return 90.0
		case .gatheringListHeader:
			return 80.0
		case .gatheringLists:
			return 90.0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.viewModel.getCellTypes()[indexPath.row] {
		case .recommendGatheringHeader:
			if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
				cell.configure(withTitle: "추천 소모임")
				cell.backgroundColor = .lp_background_white
				return cell
			}
		case .recommendGatherings:
			if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
				cell.backgroundColor = .lp_background_white
				let startIndex = 1
				let gatheringIndex = indexPath.row - startIndex
				if gatheringIndex < viewModel.recommendGatherings.count {
					let gathering = viewModel.recommendGatherings[gatheringIndex]
					cell.configure(with: gathering)
				}
				return cell
			}
		case .gatheringListHeader:
			if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
				cell.backgroundColor = .lp_background_white
				cell.configure(withTitle: "소모임 리스트")
				return cell
			}
		case .gatheringLists:
			if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
				cell.backgroundColor = .lp_background_white
				let startIndex = viewModel.getRecommendGatheringCount() + 2
				let gatheringIndex = indexPath.row - startIndex
				if gatheringIndex < viewModel.gatheringLists.count {
					let gathering = viewModel.gatheringLists[gatheringIndex]
					cell.configure(with: gathering)
				}
				return cell
			}
		}
		return UITableViewCell()
	}
}
