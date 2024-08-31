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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .lp_background_white
        [navigationView, tableView, ].forEach {
            self.view.addSubview($0)
        }
        self.navigationController?.isNavigationBarHidden = true
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    }
    
    private func showUserView<T: UIView>(existingView: inout T?,user: GatheringMember,userData: LetportsUser,gathering: Gathering,joinDelegate: ManageViewJoinDelegate?,pendingDelegate: ManageViewPendingDelegate?) {
        // 기존 뷰가 nil인지 확인
        if existingView == nil {
            // ManageUserView 생성
            let manageUserView = ManageUserView()
            manageUserView.joindelegate = joinDelegate
            manageUserView.pendingdelegate = pendingDelegate
            manageUserView.configure(user: user, gathering: gathering, userData: userData)
            
            // ManageUserView를 화면에 추가
            self.view.addSubview(manageUserView)
            manageUserView.translatesAutoresizingMaskIntoConstraints = false
            
            // Autolayout 제약 추가
            NSLayoutConstraint.activate([
                manageUserView.topAnchor.constraint(equalTo: view.topAnchor),
                manageUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                manageUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                manageUserView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            // 기존 뷰 포인터에 새로 만든 뷰 할당
            existingView = manageUserView as? T
        } else {
            print("ManageUserView already exists.")
        }
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension GatherSettingVC: ManageViewJoinDelegate, ManageViewPendingDelegate {
    func cancelAction(_ manageUserView: ManageUserView) {
        removeManageUserView()
        self.viewModel.loadData()
    }
    
    func expelGathering(_ manageUserView: ManageUserView,userUid: String, nickName: String) {
        viewModel.expelUser(userUid: userUid, nickName: nickName)
               .sink(receiveCompletion: { [weak self] completion in
                   guard let self = self else { return }
                   DispatchQueue.main.async {
                       switch completion {
                       case .finished:
                           self.showAlert(title: "추방", message: "\(nickName)의 추방이 완료되었습니다.")
                           self.removeManageUserView()  // 뷰 제거
                           self.viewModel.loadData()
                       case .failure(let error):
                           self.showAlert(title: "오류", message: self.viewModel.errorToString(error: error))
                       }
                   }
               }, receiveValue: { _ in })
               .store(in: &cancellables)
    }
    
    func denyJoinGathering(_ manageUserView: ManageUserView,userUid: String, nickName: String) {
        viewModel.denyUser(userUid: userUid)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch completion {
                    case .finished:
                        self.showAlert(title: "가입거절", message: "\(nickName)의 가입거절이 완료되었습니다.")
                        self.removeManageUserView()
                        self.viewModel.loadData()// 수정된 부분
                    case .failure(let error):
                        self.showAlert(title: "오류", message: self.viewModel.errorToString(error: error))
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func apporveJoinGathering(_ manageUserView: ManageUserView,userUid: String, nickName: String) {
        viewModel.approveUser(userUid: userUid)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch completion {
                    case .finished:
                        self.showAlert(title: "가입승인", message: "\(nickName)의 가입승인이 완료되었습니다.")
                        self.removeManageUserView()
                        self.viewModel.loadData()
                    case .failure(let error):
                        self.showAlert(title: "오류", message: self.viewModel.errorToString(error: error))
                    }
                }
            },receiveValue: { _ in })
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
            viewModel.deleteGathering()
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
