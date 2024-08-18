//
//  GatheringDetailVC.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

final class GatheringDetailVC: UIViewController {
	private let floatingButton: FloatingButton = {
		let button = FloatingButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private let tableView: UITableView = {
		let tv = UITableView()
		tv.separatorStyle = .none
		tv.backgroundColor = .lp_background_white
		tv.rsgistersCell(cellClasses: GatheringDetailImageTVCell.self,
						 SeperatorLineTVCell.self,
						 GatheringDetailInfoTVCell.self,
						 GatheringDetailProfileTVCell.self,
						 BoardButtonTVCell.self,
						 GatheringDetailBoardTVCell.self)
		tv.translatesAutoresizingMaskIntoConstraints = false
		return tv
	}()
	
	private var viewModel: GatheringDetailVM
	
	init(viewModel: GatheringDetailVM) {
		self.viewModel = GatheringDetailVM()
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
		setupUI()
		setupFloatingButton()
	}
	
	// MARK: - Setup
	private func setupUI() {
		[tableView].forEach{
			self.view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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


extension GatheringDetailVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.viewModel.getDetailCellTypes()[indexPath.row] {
		case .gatheringImageTitle:
			if let cell: GatheringDetailImageTVCell  = tableView.loadCell(indexPath: indexPath) {
				let headerData = viewModel.GatheringHeaders.first // 첫 번째 데이터를 사용
				if let data = headerData {
					cell.configureCell(data: data)
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
				return cell
			}
		case .gatheringBoard:
			if let cell: GatheringDetailBoardTVCell = tableView.loadCell(indexPath: indexPath) {
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
		case .gatheringImageTitle:
			return UITableView.automaticDimension
		case .gatheringInfo:
			return UITableView.automaticDimension
		case .gatheringProfile:
			return 80
		case .boardButtonType:
			return UITableView.automaticDimension
		case .gatheringBoard:
			if let cell = tableView.cellForRow(at: indexPath) as? GatheringDetailBoardTVCell {
				return cell.calculateTableViewHeight()
			}
			return UITableView.automaticDimension
		case .separator:
			return 1
		}
	}
}


#Preview {
	GatheringDetailVC(viewModel: GatheringDetailVM())
}
