//
//  GatheringDetailVC.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit
import Combine

protocol GatheringDetailDelegate: AnyObject {
	func didTapEditBtn()
	func didTapProfileImage()
	func didTapSettingBtn()
	func didTapCell(boardPost: Post)
}

final class GatheringDetailVC: UIViewController {
	private lazy var navigationView: CustomNavigationView = {
		let screenType: ScreenType
		let gatheringName = viewModel.gathering?.gatherName ?? "모임"
		
		if viewModel.isMaster {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .gear)
		} else if viewModel.membershipStatus == .joined {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .ellipsis)
		} else {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .empty)
		}
		
		let cnv = CustomNavigationView(isLargeNavi: .small, screenType: screenType)
		cnv.delegate = self
		cnv.backgroundColor = .lp_background_white
		cnv.translatesAutoresizingMaskIntoConstraints = false
		return cnv
	}()
	
	private lazy var joinBtn: JoinBtn = {
		let btn = JoinBtn()
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.addTarget(self, action: #selector(joinButtonTap), for: .touchUpInside)
		return btn
	}()
	
	private var postBtn: PostBtn = {
		let btn = PostBtn()
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
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
	weak var delegate: GatheringDetailDelegate?
	private var joinBackground: JoinBackgroundView?
	private var joinView: JoinView?
	
	init(viewModel: GatheringDetailVM) {
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
		viewModel.loadData()
		self.delegate = self
		print("Join button action set: \(joinBtn.actions(forTarget: self, forControlEvent: .touchUpInside) ?? [])")
	}
	
	// MARK: - bindVm
	private func bindViewModel() {
		viewModel.$gathering
			.receive(on: RunLoop.main)
			.sink { [weak self] gathering in
				self?.updateUI(with: gathering)
			}
			.store(in: &cancellables)
		
		viewModel.$membershipStatus
			.receive(on: RunLoop.main)
			.sink { [weak self] status in
				self?.updateJoinBtn(for: status)
				self?.boardWritewBtn(for: status)
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
	
	private func updateUI(with gathering: Gathering?) {
		guard let gathering = gathering else { return }
		
		let gatheringName = gathering.gatherName
		let screenType: ScreenType
		
		if viewModel.isMaster {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .gear)
		} else if viewModel.membershipStatus == .joined {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .ellipsis)
		} else {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .empty)
		}
		
		navigationView.screenType = screenType
		tableView.reloadData()
	}
	
	private func updateJoinBtn(for status: MembershipStatus) {
		switch status {
		case .notJoined:
			joinBtn.setTitle("가입하기", for: .normal)
			joinBtn.isHidden = false
			print("Join button visible: not joined")
		case .pending:
			joinBtn.setTitle("가입대기", for: .normal)
			joinBtn.backgroundColor = .lightGray
			joinBtn.isHidden = false
			print("Join button visible: pending")
		case .joined:
			joinBtn.isHidden = true
			print("Join button hidden: already joined")
		}
	}
	
	private func boardWritewBtn(for status: MembershipStatus) {
		switch status {
		case .notJoined, .pending:
			postBtn.setVisible(false)
		case .joined:
			postBtn.setVisible(true)
		}
	}
	
	
	// MARK: - Setup
	private func setupUI() {
		self.view.backgroundColor = .lp_background_white
		
		[navigationView, tableView, joinBtn, postBtn].forEach {
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
			
			joinBtn.widthAnchor.constraint(equalToConstant: 300),
			joinBtn.heightAnchor.constraint(equalToConstant: 50),
			joinBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			joinBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			
			postBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			postBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			postBtn.widthAnchor.constraint(equalToConstant: 60),
			postBtn.heightAnchor.constraint(equalToConstant: 60)
		])
	}
}

// MARK: - extension

extension GatheringDetailVC: GatheringDetailDelegate {
	func didTapCell(boardPost: Post) {
		viewModel.didTapBoardCell(boardPost: boardPost)
		print("[\(Date())]GatheringDetailVC: 셀 탭 이벤트 전달받음")
	}
	
	func didTapEditBtn() {
		// 모임장편집버튼
	}
	
	func didTapProfileImage() {
		// 프로필버튼
	}
	
	
	func didTapSettingBtn() {
		// 셋팅버튼
	}
}

extension GatheringDetailVC: BoardButtonTVCellDelegate {
	func didSelectBoardType(_ type: BoardButtonType) {
		viewModel.selectedBoardType = type
		tableView.reloadData()
	}
}

extension GatheringDetailVC: CustomNavigationDelegate {
	func smallRightButtonDidTap() {
		print("samll")
	}
	
	func backButtonDidTap() {
	}
}

extension GatheringDetailVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.viewModel.getDetailCellTypes()[indexPath.row] {
		case .gatheringImage:
			if let cell: GatheringImageTVCell = tableView.loadCell(indexPath: indexPath) {
				let gatheringImage = viewModel.gathering?.gatherImage
				cell.configureCell(data: gatheringImage)
				return cell
			}
		case .gatheringTitle:
			if let cell: GatheringTitleTVCell = tableView.loadCell(indexPath: indexPath),
			   let gathering = viewModel.gathering {
				cell.configureCell(data: gathering,
								   currentUser: viewModel.getCurrentUserInfo(),
								   masterNickname: viewModel.masterNickname)
				return cell
			}
		case .separator:
			if let cell: SeperatorLineTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.configureCell(height: 1)
				return cell
			}
		case .gatheringInfo:
			if let cell: GatheringDetailInfoTVCell = tableView.loadCell(indexPath: indexPath),
			   let gathering = viewModel.gathering {
				cell.configure(with: gathering.gatherInfo)
				return cell
			}
		case .gatheringProfile:
			if let cell: GatheringDetailProfileTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.members = viewModel.gathering?.gatheringMembers ?? []
				return cell
			}
		case .boardButtonType:
			if let cell: BoardButtonTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.delegate = self
				return cell
			}
		case .gatheringBoard:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "GatheringDetailBoardTVCell",
														for: indexPath) as? GatheringDetailBoardTVCell {
				cell.board = viewModel.filteredBoardData
				cell.membershipStatus = viewModel.membershipStatus
				cell.delegate = self
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
			if let cell = self.tableView.cellForRow(at: indexPath) as? GatheringDetailInfoTVCell {
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
	
	// 가입화면
	private func showUserView<T: UIView>(viewType: T.Type, existingView: inout T?, gathering: Gathering, width: CGFloat = 361, height: CGFloat = 468) {
		// 이미 화면에 해당 뷰가 있는지 확인
		if existingView == nil {
			let joinBackView = JoinBackgroundView(frame: self.view.bounds)
			self.joinBackground = joinBackView
			self.view.addSubview(joinBackView)
			NSLayoutConstraint.activate([
				joinBackView.topAnchor.constraint(equalTo: view.topAnchor),
				joinBackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				joinBackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				joinBackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			])
			// 뷰를 생성하고 설정
			let userViewFrame = CGRect(x: 0, y: 0, width: width, height: height)
			existingView = T(frame: userViewFrame)
			
			
			if let userView = existingView as? JoinView {
				userView.configure(with: gathering)
			}
			
			if let userView = existingView {
				userView.center = view.center
				
				self.view.addSubview(userView)
				userView.translatesAutoresizingMaskIntoConstraints = false
				
				NSLayoutConstraint.activate([
					userView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
					userView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
					userView.widthAnchor.constraint(equalToConstant: width),
					userView.heightAnchor.constraint(equalToConstant: height)
				])
			}
		}
	}
	// MARK: - objc메소드
	
	@objc private func joinButtonTap() {
		print("버튼이 눌렸다")
		showUserView(viewType: JoinView.self, existingView: &joinView, gathering: viewModel.gathering!)
		
	}
	
	@objc private func editBtnTap() {
		print("편집버튼")
	}
}

#Preview {
	GatheringDetailVC(viewModel: GatheringDetailVM(currentUser: GatheringDetailVM.dummyUser))
}
