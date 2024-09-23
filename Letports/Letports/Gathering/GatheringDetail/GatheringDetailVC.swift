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
        let cnv = CustomNavigationView(isLargeNavi: .small,
                                       screenType: .smallGathering(gatheringName: "",
                                                                   btnName: .empty))
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var joinBtn: JoinBtn = {
        let btn = JoinBtn()
        btn.configure(logoHex: viewModel.teamColor ?? "")
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(joinBtnTap), for: .touchUpInside)
        return btn
    }()
    
    private lazy var postBtn: PostBtn = {
        let btn = PostBtn()
        btn.delegate = self
        btn.configure(logoHex: viewModel.teamColor ?? "")
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
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
    
    private lazy var loadingIndicatorView: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.hideLoadingIndicator()
                    
                }
            }
            .store(in: &cancellables)
        
        viewModel.$gathering
            .zip(viewModel.$membershipStatus, viewModel.$isMaster)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gathering, status, _ in
                self?.updateUI(with: gathering)
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
        switch status {
        case .notJoined:
            joinBtn.setTitle("가입하기", for: .normal)
            joinBtn.backgroundColor = UIColor(hex: viewModel.teamColor ?? "")
            scrollView.isHidden = false
        case .pending:
            joinBtn.setTitle("가입신청 취소", for: .normal)
            joinBtn.backgroundColor = UIColor(hex: viewModel.teamColor ?? "")
            scrollView.isHidden = false
        case .joined:
            scrollView.isHidden = true
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
        
        if viewModel.membershipStatus == .joined {
            if viewModel.isMaster {
                screenType = .smallGathering(gatheringName: gatheringName, btnName: .gear)
            } else {
                screenType = .smallGathering(gatheringName: gatheringName, btnName: .ellipsis)
            }
        } else if viewModel.membershipStatus == .pending {
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
        
        [navigationView, tableView, scrollView, postBtn].forEach {
            self.view.addSubview($0)
        }
        
        scrollView.addSubview(joinBtn)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 70), // 스크롤 뷰의 높이 설정
            
            joinBtn.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            joinBtn.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            joinBtn.widthAnchor.constraint(equalToConstant: 300),
            joinBtn.heightAnchor.constraint(equalToConstant: 50),
            
            postBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            postBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            postBtn.widthAnchor.constraint(equalToConstant: 60),
            postBtn.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            // loadingIndicatorView를 window에 추가
            window.addSubview(self.loadingIndicatorView)
            
            // Auto Layout 제약 설정
            NSLayoutConstraint.activate([
                self.loadingIndicatorView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                self.loadingIndicatorView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                self.loadingIndicatorView.topAnchor.constraint(equalTo: window.topAnchor),
                self.loadingIndicatorView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
            
            // 로딩 뷰 표시
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimating()
            window.layoutIfNeeded()
        }
    }
    
    private func hideLoadingIndicator() {
        loadingIndicatorView.stopAnimating()
        loadingIndicatorView.isHidden = true
        loadingIndicatorView.removeFromSuperview()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard viewModel.membershipStatus != .joined else {
            return
        }
        
        let yOffset = scrollView.contentOffset.y
        if yOffset > 100 {
            hideJoinButton()
        } else {
            showJoinButton()
        }
    }
    
    private func hideJoinButton() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.joinBtn.alpha = 0
                self.scrollView.isHidden = true
            }
        }
    }
    
    private func showJoinButton() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.joinBtn.alpha = 1
                self.scrollView.isHidden = false
            }
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
            showAlert(title: "알림", message: "가입신청을 취소하시겠습니까?", confirmTitle: "확인", cancelTitle: "취소") {
                self.viewModel.confirmCancelWaiting()
            }
        case .joined:
            break
        }
    }
    
    @objc private func refreshData() {
        performRefresh()
    }
    
    // 가입뷰 처리
    private func showUserView<T: UIView>(existingView: inout T?, gathering: Gathering) {
        if existingView == nil {
            let manageUserView = JoinView()
            manageUserView.delegate = self
            manageUserView.configure(with: gathering)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                window.addSubview(manageUserView)
                window.bringSubviewToFront(manageUserView)
                NSLayoutConstraint.activate([
                    manageUserView.topAnchor.constraint(equalTo: window.topAnchor),
                    manageUserView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                    manageUserView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                    manageUserView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
                ])
                DispatchQueue.main.async {
                    self.joinView = manageUserView
                }
            }
        }
    }
    
    private func removeJoinView() {
        if let joinView = self.joinView {
            DispatchQueue.main.async {
                self.view.bringSubviewToFront(joinView)
                UIView.animate(withDuration: 0.3, animations: {
                    joinView.alpha = 0
                }) { _ in
                    joinView.removeFromSuperview()
                    self.joinView = nil
                    self.joinView?.delegate = nil
                }
            }
        }
    }
    
    private func performRefresh() {
        viewModel.loadData()
        self.refreshControl.endRefreshing()
    }
}

// MARK: - extension

extension GatheringDetailVC: JoinViewDelegate {
    func joinViewDidTapCancel(_ joinView: JoinView) {
        removeJoinView()
    }
    // 가입 신청 버튼
    func joinViewDidTapJoin(_ joinView: JoinView, answer: String) {
        viewModel.joinGathering(answer: answer)
            .flatMap { [weak self] _ -> AnyPublisher<Void, FirestoreError> in
                guard let self = self,
                      let gatherName = self.viewModel.gathering?.gatherName,
                      let gatheringMaster = self.viewModel.gathering?.gatheringMaster,
                      let nickname = UserManager.shared.currentUser?.nickname else {
                    return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "모임 이름, 마스터 정보 또는 사용자 닉네임을 가져올 수 없습니다."])))
                        .eraseToAnyPublisher()
                }
                return NotificationService.shared.sendPushNotificationByUID(uid: gatheringMaster,
                                                                            title: "알림",
                                                                            body: "\(nickname)님이 \(gatherName)에 가입을 신청했습니다.")
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.removeJoinView()
                    self?.viewModel.loadData()
                case .failure(let error):
                    self?.showAlert(title: "에러", message: "\(error)", confirmTitle: "확인", onConfirm: {
                    })
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
}

extension GatheringDetailVC: GatheringDetailDelegate {
    func didTapEditBtn() {
        viewModel.showGatheringEditView()
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
                viewModel.presentActionSheet()
            }
        }
    }
    func backBtnDidTap() {
        viewModel.gatheringDetailBackBtnTap()
    }
}

extension GatheringDetailVC: PostBtnDelegate {
    func didTapPostUploadBtn(type: PostType) {
        self.viewModel.didTapUploadBtn(type: type)
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
                                   masterNickname: viewModel.masterNickname, logoHex: viewModel.teamColor ?? "")
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
                if let teamColor = viewModel.teamColor {
                    cell.configure(teamColor: teamColor)
                }
                return cell
            }
        case .gatheringBoard:
            if let cell: GatheringDetailBoardTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.viewModel = viewModel
                cell.board = viewModel.filteredBoardData
                cell.membershipStatus = viewModel.membershipStatus
                cell.updateBoard()
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
        case .gatheringProfile:
            return 80
        case .gatheringBoard:
            return viewModel.calculateBoardHeight()
        default:
            return UITableView.automaticDimension
        }
    }
    
    
}


