//
//  GatheringDetailVC.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit
import Combine

protocol GatheringDetailDelegate: AnyObject {
	func didTapProfileImage(profile: LetportsUser)
	func didTapCell(boardPost: Post)
}

final class GatheringDetailVC: UIViewController, GatheringTitleTVCellDelegate {
	private lazy var navigationView: CustomNavigationView = {
		let screenType: ScreenType
		let cnv = CustomNavigationView(isLargeNavi: .small, screenType: .smallGathering(gatheringName: "모임", btnName: .ellipsis))
		cnv.delegate = self
		cnv.backgroundColor = .lp_background_white
		cnv.translatesAutoresizingMaskIntoConstraints = false
		return cnv
	}()
	
	private lazy var joinBtn: JoinBtn = {
		let btn = JoinBtn()
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.addTarget(self, action: #selector(joinBtnTap), for: .touchUpInside)
		return btn
	}()
	
	private lazy var postBtn: PostBtn = {
		let btn = PostBtn()
		btn.delegate = self
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
						 CurrentMemTVCell.self,
						 GatheringDetailProfileTVCell.self,
						 BoardBtnTVCell.self,
						 GatheringDetailBoardTVCell.self)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.rowHeight = UITableView.automaticDimension
		return tv
	}()
	
	private var viewModel: GatheringDetailVM
	private var cancellables: Set<AnyCancellable> = []
	weak var delegate: GatheringDetailDelegate?
	var joinView: JoinView?
	var isExpanded = false
	
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
		self.delegate = self
		viewModel.selectedBoardType = .all
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.loadData()
	}
	
	// MARK: - bindVm
	private func bindViewModel() {
		viewModel.$gathering
			.receive(on: DispatchQueue.main)
			.sink { [weak self] gathering in
				self?.updateUI(with: gathering)
			}
			.store(in: &cancellables)
		
		viewModel.$membershipStatus
			.receive(on: DispatchQueue.main)
			.sink { [weak self] status in
				self?.updateJoinBtn(for: status)
				self?.boardWritewBtn(for: status)
			}
			.store(in: &cancellables)
		
		viewModel.$selectedBoardType
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
				self?.view.setNeedsLayout()
				self?.view.layoutIfNeeded()
			}
			.store(in: &cancellables)
		
		viewModel.$memberData
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)
	}
	
	private func updateJoinBtn(for status: MembershipStatus) {
		print("status: \(status)")
		switch status {
		case .notJoined:
			joinBtn.setTitle("가입하기", for: .normal)
			joinBtn.backgroundColor = .lp_main
			joinBtn.isHidden = false
		case .pending:
			joinBtn.setTitle("가입대기", for: .normal)
			joinBtn.backgroundColor = .lightGray
			joinBtn.isHidden = false
		case .joined:
			joinBtn.isHidden = true
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
	// 커스텀네비
	private func updateUI(with gathering: Gathering?) {
		guard let gathering = gathering else { return }
		
		let gatheringName = gathering.gatherName
		let screenType: ScreenType
		
		postBtn.isMaster = viewModel.isMaster
		
		if viewModel.isMaster {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .gear)
		} else if viewModel.membershipStatus == .joined {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .ellipsis)
		} else if viewModel.membershipStatus == .pending{
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .empty)
		} else {
			screenType = .smallGathering(gatheringName: gatheringName, btnName: .empty)
		}
		navigationView.screenType = screenType
		self.view.setNeedsLayout()
		tableView.reloadData()
	}
	// 레이아웃
	private func setupUI() {
		self.navigationController?.isNavigationBarHidden = true
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
extension GatheringDetailVC: JoinViewDelegate {
	func joinViewDidTapCancel(_ joinView: JoinView) {
		removeJoinView()
	}
	
	func joinViewDidTapJoin(_ joinView: JoinView, answer: String) {
		viewModel.joinGathering(answer: answer)
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("가입 처리가 완료되었습니다.")
					self?.removeJoinView()
					self?.viewModel.loadData() // 데이터 새로고침
				case .failure(let error):
					print("가입 처리 중 오류 발생: \(error)")
					self?.showError(message: "가입 처리 중 오류가 발생했습니다.")
				}
			}, receiveValue: { _ in })
			.store(in: &cancellables)
		print("사용자가 가입을 시도했습니다. 답변: \(answer)")
	}
	
	// 가입뷰 처리
	private func showUserView<T: UIView>(existingView: inout T?, gathering: Gathering) {
		if existingView == nil {
			let manageUserView = JoinView()
			manageUserView.delegate = self
			manageUserView.configure(with: gathering)
			self.view.addSubview(manageUserView)
			NSLayoutConstraint.activate([
				manageUserView.topAnchor.constraint(equalTo: view.topAnchor),
				manageUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				manageUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				manageUserView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			])
			DispatchQueue.main.async {
				self.joinView = manageUserView
			}
		}
	}
	
	private func removeJoinView() {
		if let joinView = self.joinView {
			self.view.bringSubviewToFront(joinView)
			UIView.animate(withDuration: 0.3, animations: {
				joinView.alpha = 0
			}) { _ in
				joinView.removeFromSuperview()
				self.joinView = nil
			}
		}
	}
	
	private func showError(message: String) {
		let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	private func showCancelWaitingConfirmation() {
		let alert = UIAlertController(title: "가입 대기 취소", message: "가입 대기를 취소하시겠습니까?", preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "나가기", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "가입 대기 취소", style: .destructive, handler: { [weak self] _ in
			self?.viewModel.confirmCancelWaiting()
		}))
		
		present(alert, animated: true, completion: nil)
	}
}

extension GatheringDetailVC: GatheringDetailDelegate {
	func didTapEditBtn() {
		
	}
	
	func didTapProfileImage(profile: LetportsUser) {
		viewModel.didTapProfile(member: profile)
	}
	
	func didTapCell(boardPost: Post) {
		viewModel.didTapBoardCell(boardPost: boardPost)
	}
}

extension GatheringDetailVC: BoardBtnTVCellDelegate {
	func didSelectBoardType(_ type: PostType) {
		viewModel.selectedBoardType = type
	}
}

extension GatheringDetailVC: CustomNavigationDelegate {
	func smallRightBtnDidTap() {
		if viewModel.membershipStatus == .joined {
			if viewModel.isMaster {
				viewModel.pushGatherSettingView()
			} else {
				viewModel.showActionSheet()
			}
		}
	}
	func backBtnDidTap() {
		viewModel.gatheringDetailBackBtnTap()
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
				cell.delegate = self
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
				cell.expandBtnTap = { [weak self] isExpanded in
					self?.tableView.beginUpdates()
					self?.tableView.endUpdates()
				}
				return cell
			}
		case .gatheringProfile:
			if let cell: GatheringDetailProfileTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.members = viewModel.memberData
				cell.delegate = self
				return cell
			}
		case .boardButtonType:
			if let cell: BoardBtnTVCell = tableView.loadCell(indexPath: indexPath) {
				cell.delegate = self
				return cell
			}
		case .gatheringBoard:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "GatheringDetailBoardTVCell",
														for: indexPath) as? GatheringDetailBoardTVCell {
				cell.viewModel = viewModel
				cell.board = viewModel.filteredBoardData
				cell.membershipStatus = viewModel.membershipStatus
				cell.delegate = self
				return cell
			}
		case .currentMemLabel:
			if let cell: CurrentMemTVCell = tableView.loadCell(indexPath: indexPath) {
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
			return viewModel.calculateBoardHeight()
		case .separator:
			return 1
		case .currentMemLabel:
			return UITableView.automaticDimension
		}
	}
	
	// MARK: - objc메소드
	
	@objc private func joinBtnTap() {
		switch viewModel.membershipStatus {
		case .notJoined:
			guard let gathering = viewModel.gathering else {
				return
			}
			showUserView(existingView: &joinView, gathering: gathering)
		case .pending:
			showCancelWaitingConfirmation()
		case .joined:
			break
		}
	}
}

extension GatheringDetailVC: PostBtnDelegate {
	func didTapPostUploadBtn(type: PostType) {
		self.viewModel.didTapUploadBtn(type: type)
	}
}
