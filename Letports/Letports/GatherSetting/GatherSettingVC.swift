//
//  GatherSettingVC.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import UIKit
import Combine

protocol ManageViewPendingDelegate: AnyObject {
    func denyJoinGathering(_ manageUserView: ManageUserView, userUid: String, nickName: String)
    func apporveJoinGathering(_ manageUserView: ManageUserView,userUid: String, nickName: String)
    func cancelAction(_ manageUserView: ManageUserView)
}

protocol ManageViewJoinDelegate: AnyObject {
    func cancelAction(_ manageUserView: ManageUserView)
    func expelGathering(_ manageUserView: ManageUserView,userUid: String, nickName: String)
}

protocol GatherSettingDelegate: AnyObject {
    func deleteGathering()
}

class GatherSettingVC: UIViewController {
    
    private var viewModel: GatherSettingVM
    private var cancellables: Set<AnyCancellable> = []
    var manageUserView: ManageUserView?
    
    init(viewModel: GatherSettingVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var navigationView: CustomNavigationView = {
        let btnName: NaviButtonType
        let view = CustomNavigationView(isLargeNavi: .small, screenType: .smallGatheringSetting)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.registersCell(cellClasses: GatherSectionTVCell.self,
                         GatherUserTVCell.self,
                         GatherDeleteTVCell.self,
                         EmptyStateTVCell.self)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .lp_background_white
        return tv
    }()
    
    private lazy var loadingIndicatorView: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .lp_background_white
        [navigationView, tableView, loadingIndicatorView].forEach {
            self.view.addSubview($0)
        }
        
        tableView.refreshControl = refreshControl
        tableView.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        let mergedPublishers = Publishers.MergeMany(
            viewModel.$gathering.map { _ in }.eraseToAnyPublisher(),
            viewModel.$pendingMembers.map { _ in }.eraseToAnyPublisher(),
            viewModel.$pendingMembersData.map { _ in }.eraseToAnyPublisher(),
            viewModel.$joinedMembers.map { _ in }.eraseToAnyPublisher(),
            viewModel.$joinedMembersData.map { _ in }.eraseToAnyPublisher()
        )
        
        mergedPublishers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicatorView.startAnimating()
                } else {
                    self?.loadingIndicatorView.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshData() {
        performRefresh()
    }
    
    private func performRefresh() {
        viewModel.loadData()
        self.refreshControl.endRefreshing()
        
    }
    
    private func showUserView<T: UIView>(existingView: inout T?,user: GatheringMember,userData: LetportsUser,gathering: Gathering,joinDelegate: ManageViewJoinDelegate?,pendingDelegate: ManageViewPendingDelegate?) {
        if existingView == nil {
            
            let manageUserView = ManageUserView()
            manageUserView.joindelegate = joinDelegate
            manageUserView.pendingdelegate = pendingDelegate
            manageUserView.configure(user: user, gathering: gathering, userData: userData)
            
            self.view.addSubview(manageUserView)
            manageUserView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                manageUserView.topAnchor.constraint(equalTo: view.topAnchor),
                manageUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                manageUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                manageUserView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            existingView = manageUserView as? T
        } else {
            print("ManageUserView already exists.")
        }
    }
    
    private func showLoadingView() {
        loadingIndicatorView.isHidden = false
        loadingIndicatorView.startAnimating()
    }
    
    private func hideLoadingView() {
        loadingIndicatorView.isHidden = true
        loadingIndicatorView.stopAnimating()
    }
    
    private func removeManageUserView() {
        if let manageUserView = self.manageUserView {
            self.view.bringSubviewToFront(manageUserView)
            UIView.animate(withDuration: 0.3, animations: {
                manageUserView.alpha = 0
            }) { _ in
                print("Animation completed. Removing from superview.")
                manageUserView.removeFromSuperview()
                self.manageUserView = nil
            }
        } else {
            print("No ManageUserView to remove.")
        }
    }
}

extension GatherSettingVC: GatherSettingDelegate {
    func deleteGathering() {
        self.showAlert(title: "알림", message: "정말로 이 소모임을 삭제하시겠습니까? \n 게시글, 사진을 포함한 모든 데이터는 영구적으로 삭제되며 복구할 수 없습니다.", confirmTitle: "삭제", cancelTitle: "취소") {
            self.viewModel.deleteGatheringButtonTapped()
                .flatMap { [weak self] _ -> AnyPublisher<Void, FirestoreError> in
                    guard let self = self else {
                        return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "유저 UID 배열을 가져올 수 없습니다."])))
                            .eraseToAnyPublisher()
                    }
                    
                    let notificationPublishers = self.viewModel.allUserUIDs.map { userUid in
                        NotificationService.shared.sendPushNotificationByUID(
                            uid: userUid,
                            title: "소모임 삭제 알림",
                            body: "\(self.viewModel.gathering?.gatherName ?? "소모임")소모임이 삭제되었습니다."
                        )
                    }
                    
                    return Publishers.MergeMany(notificationPublishers)
                        .collect()
                        .map { _ in () }
                        .eraseToAnyPublisher()
                }
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self.viewModel.loadData()
                            self.showAlert(title: "알림", message: "소모임 삭제가 완료되었습니다.", confirmTitle: "확인", onConfirm: {})
                        case .failure(let error):
                            self.showAlert(title: "오류", message: self.viewModel.errorToString(error: error), confirmTitle: "확인", onConfirm: {})
                        }
                    }
                }, receiveValue: { _ in })
                .store(in: &self.cancellables)
        }
    }
}

extension GatherSettingVC: ManageViewJoinDelegate, ManageViewPendingDelegate {
    func cancelAction(_ manageUserView: ManageUserView) {
        removeManageUserView()
        self.viewModel.loadData()
    }
    
    func expelGathering(_ manageUserView: ManageUserView, userUid: String, nickName: String) {
        self.showAlert(title: "알림", message: "정말로 \(nickName)유저를  추방하시겠습니까?", confirmTitle: "추방", cancelTitle: "취소") {
            self.viewModel.expelUser(userUid: userUid)
                .flatMap { [weak self] _ -> AnyPublisher<Void, FirestoreError> in
                    guard let self = self,let gatherName = self.viewModel.gathering?.gatherName else {
                        return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "모임 이름, 마스터 정보 또는 사용자 닉네임을 가져올 수 없습니다."])))
                            .eraseToAnyPublisher()
                    }
                    return NotificationService.shared.sendPushNotificationByUID(uid: userUid,
                                                                                title: "추방 알림",
                                                                                body: "\(gatherName)소모임에서 추방되었습니다.")
                }
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self.showAlert(title: "알림", message: "\(nickName)유저의 추방이 완료되었습니다", confirmTitle: "확인", onConfirm: {})
                            self.removeManageUserView()
                            self.viewModel.loadData()
                        case .failure(let error):
                            self.showAlert(title: "오류", message: self.viewModel.errorToString(error: error), confirmTitle: "확인", onConfirm: {})
                        }
                    }
                }, receiveValue: { _ in })
                .store(in: &self.cancellables)
        }
    }
    
    func denyJoinGathering(_ manageUserView: ManageUserView, userUid: String, nickName: String) {
        viewModel.denyUser(userUid: userUid)
            .flatMap { [weak self] _ -> AnyPublisher<Void, FirestoreError> in
                guard let self = self,let gatherName = self.viewModel.gathering?.gatherName else {
                    return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "모임 이름, 마스터 정보 또는 사용자 닉네임을 가져올 수 없습니다."])))
                        .eraseToAnyPublisher()
                }
                return NotificationService.shared.sendPushNotificationByUID(uid: userUid,
                                                                            title: "가입 거절 알림",
                                                                            body: "\(gatherName)소모임의 가입이 거절되었습니다.")
            }
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch completion {
                    case .finished:
                        self.showAlert(title: "알림", message: "\(nickName)유저의 가입 거절이 완료되었습니다", confirmTitle: "확인", onConfirm: {})
                        self.removeManageUserView()
                        self.viewModel.loadData()
                    case .failure(let error):
                        self.showAlert(title: "오류", message: self.viewModel.errorToString(error: error), confirmTitle: "확인", onConfirm: {})
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    
    func apporveJoinGathering(_ manageUserView: ManageUserView, userUid: String, nickName: String) {
        viewModel.approveUser(userUid: userUid)
            .flatMap { [weak self] _ -> AnyPublisher<Void, FirestoreError> in
                guard let self = self,
                      let gatherName = self.viewModel.gathering?.gatherName else {
                    return Fail(error: FirestoreError.unknownError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "모임 이름, 마스터 정보 또는 사용자 닉네임을 가져올 수 없습니다."])))
                        .eraseToAnyPublisher()
                }
                return NotificationService.shared.sendPushNotificationByUID(uid: userUid,
                                                                            title: "가입 승인 알림",
                                                                            body: "\(gatherName)소모임에 가입되었습니다.")
            }
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch completion {
                    case .finished:
                        self.showAlert(title: "알림", message: "\(nickName)유저의 가입 승인이 완료되었습니다", confirmTitle: "확인", onConfirm: {})
                        self.removeManageUserView()
                        self.viewModel.loadData()
                    case .failure(let error):
                        self.showAlert(title: "오류", message: self.viewModel.errorToString(error: error), confirmTitle: "확인", onConfirm: {})
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

extension GatherSettingVC: CustomNavigationDelegate {
    func backBtnDidTap() {
        viewModel.gatherSettingBackBtnTap()
    }
}

extension GatherSettingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .pendingGatheringUserTtitle, .joiningGatheringUserTitle, .settingTitle, .deleteGathering:
            return 40.0
        case .pendingGatheringUser, .joiningGatheringUser, .joinEmptyState, .pendingEmptyState:
            return 80.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .pendingGatheringUser:
            let startIndex = 1
            let userIndex = indexPath.row - startIndex
            if userIndex < viewModel.pendingMembers.count {
                let user = viewModel.pendingMembers[userIndex]
                let userdata = viewModel.pendingMembersData[userIndex]
                if let gathering = viewModel.gathering {
                    showUserView(existingView: &manageUserView, user: user, userData: userdata, gathering: gathering, joinDelegate: nil,
                                 pendingDelegate: self)
                }
            }
        case .joiningGatheringUser:
            var startIndex = 0
            if viewModel.pendingMembers.count == 0 {
                startIndex = 3
            } else {
                startIndex = 2 + viewModel.pendingMembers.count
            }
            let userIndex = indexPath.row - startIndex
            if userIndex < viewModel.joinedMembers.count {
                let user = viewModel.joinedMembers[userIndex]
                let userdata = viewModel.joinedMembersData[userIndex]
                if let gathering = viewModel.gathering {
                    showUserView(existingView: &manageUserView, user: user, userData: userdata, gathering: gathering, joinDelegate: self,
                                 pendingDelegate: nil)
                }
            }
        case .deleteGathering:
            deleteGathering()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellType = viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .joiningGatheringUser,.pendingGatheringUser, .deleteGathering:
            return indexPath
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .pendingGatheringUserTtitle:
            if let cell: GatherSectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title:"가입 신청 인원")
                return cell
            }
        case .pendingGatheringUser:
            if let cell: GatherUserTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 1
                let userIndex = indexPath.row - startIndex
                if userIndex < viewModel.pendingMembersData.count {
                    let user = viewModel.pendingMembersData[userIndex]
                    let userData = viewModel.pendingMembers[userIndex]
                    cell.configure(user:user, userData: userData, joined: false)
                }
                return cell
            }
        case .joiningGatheringUserTitle:
            if let cell: GatherSectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title:"가입 중 인원")
                return cell
            }
        case .joiningGatheringUser:
            if let cell: GatherUserTVCell  = tableView.loadCell(indexPath: indexPath) {
                var startIndex = 0
                if viewModel.pendingMembers.count == 0 {
                    startIndex = 3
                } else {
                    startIndex = 2 + viewModel.pendingMembers.count
                }
                let userIndex = indexPath.row - startIndex
                if userIndex < viewModel.joinedMembersData.count {
                    let user = viewModel.joinedMembersData[userIndex]
                    let userData = viewModel.joinedMembers[userIndex]
                    cell.configure(user:user, userData: userData, joined: true)
                }
                return cell
            }
        case .settingTitle:
            if let cell: GatherSectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "설정")
                return cell
            }
        case .deleteGathering:
            if let cell: GatherDeleteTVCell  = tableView.loadCell(indexPath: indexPath) {
                return cell
            }
        case .pendingEmptyState:
            if let cell: EmptyStateTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "가입 대기중인 인원이 없습니다.")
                return cell
            }
        case .joinEmptyState:
            if let cell: EmptyStateTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title:"가입 중인 인원이 없습니다.")
                return cell
            }
        }
        return UITableViewCell()
    }
}
