import UIKit
import FirebaseAuth
import Combine
import Kingfisher

protocol ProfileDelegate: AnyObject {
    func editProfileBtnDidTap()
    func reloadProfileData()
}

class ProfileVC: UIViewController {
    private var viewModel: ProfileVM
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ProfileVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var navigationView: CustomNavigationView = {
        let view: CustomNavigationView
        switch viewModel.profileType {
        case .myProfile:
            view = CustomNavigationView(isLargeNavi: .large, screenType: .largeProfile(btnName: .gear))
        case .userProfile:
            view = CustomNavigationView(isLargeNavi: .small, screenType: .smallProfile(btnName: .ellipsis))
        }
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.registersCell(cellClasses: SectionTVCell.self,
                         ProfileTVCell.self,
                         GatheringTVCell.self,
                         EmptyStateTVCell.self)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .lp_background_white
        return tv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .lp_background_white
        
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        
        if viewModel.profileType == .myProfile {
            tableView.refreshControl = refreshControl
        }
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
        ])
    }
    
    private func bindViewModel() {
        let publisher = viewModel.profileType == .myProfile
        ? Publishers.Merge4(
            viewModel.$user.map { _ in () },
            viewModel.$myGatherings.map { _ in () },
            viewModel.$pendingGatherings.map { _ in () },
            viewModel.$masterUsers.map { _ in () }
        ).eraseToAnyPublisher()
        : Publishers.Merge3(
            viewModel.$user.map { _ in () },
            viewModel.$userGatherings.map { _ in () },
            viewModel.$masterUsers.map { _ in () }
        ).eraseToAnyPublisher()
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_) in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshData() {
        performRefresh()
    }
    
    func presentActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "신고하기", style: .destructive) { [weak self] _ in
            if let user = self?.viewModel.user?.nickname {
                if user == UserManager.shared.currentUser?.nickname {
                    self?.showAlert(title: "알림", message: "자신은 신고할수 없습니다.", confirmTitle: "확인", onConfirm: {
                    })
                } else {
                    self?.showAlert(title: "알림", message: "\(user)유저가 신고되었습니다.", confirmTitle: "확인", onConfirm: {
                    })
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    private func performRefresh() {
        switch viewModel.profileType {
        case .myProfile:
            viewModel.loadUser(user:UserManager.shared.getUserUid()) {
                self.refreshControl.endRefreshing()
            }
        case .userProfile:
            if let userUID = viewModel.currentUserUid {
                viewModel.loadUser(user: userUID) {
                    self.refreshControl.endRefreshing()
                }
            } else {
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellType = viewModel.getCellTypes()[indexPath.row]
        switch viewModel.profileType {
        case .myProfile:
            switch cellType {
            case .profile, .myGatherings, .pendingGatherings:
                return indexPath
            default:
                return nil
            }
        case .userProfile:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.profileType == .myProfile else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .myGatherings:
            let startIndex = 2
            let gatheringIndex = indexPath.row - startIndex
            if gatheringIndex >= 0 && gatheringIndex < viewModel.myGatherings.count {
                let gathering = viewModel.myGatherings[gatheringIndex]
                self.viewModel.gatheringCellDidTap(gatheringUID: gathering.gatheringUid)
            }
        case .pendingGatherings:
            var startIndex = 3
            if viewModel.myGatherings.count == 0 {
                startIndex = 4
            } else {
                startIndex = 3 + viewModel.myGatherings.count
            }
            let gatheringIndex = indexPath.row - startIndex
            if gatheringIndex >= 0 && gatheringIndex < viewModel.pendingGatherings.count {
                let gathering = viewModel.pendingGatherings[gatheringIndex]
                self.viewModel.gatheringCellDidTap(gatheringUID: gathering.gatheringUid)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .profile:
            return 120.0
        case .myGatheringHeader, .pendingGatheringHeader, .userGatheringHeader:
            return 40.0
        case .myGatherings, .pendingGatherings, .userGatherings, .myGatheringEmptyState, .pendingGatheringEmptyState:
            return 100.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .profile:
            if let cell: ProfileTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                if let user = viewModel.user {
                    cell.configure(user: user, isEditable: viewModel.profileType == .myProfile)
                }
                return cell
            }
        case .myGatheringHeader:
            if let cell: SectionTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "내 소모임",count: viewModel.myGatherings.count)
                return cell
            }
        case .myGatherings:
            if let cell: GatheringTVCell = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 2
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.myGatherings.count {
                    let gathering = viewModel.myGatherings[gatheringIndex]
                    if let user = viewModel.user {
                        if let masterUser = viewModel.masterUsers[gathering.gatheringMaster] {
                            cell.selectionStyle = .default
                            cell.configure(with: gathering, with: user, with: masterUser)
                        } else {
                            viewModel.fetchMasterUser(masterId: gathering.gatheringMaster)
                        }
                    }
                }
                return cell
            }
        case .pendingGatheringHeader:
            if let cell: SectionTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "가입 대기중 소모임", count: viewModel.pendingGatherings.count)
                return cell
            }
        case .pendingGatherings:
            if let cell: GatheringTVCell = tableView.loadCell(indexPath: indexPath) {
                var startIndex = 0
                if viewModel.myGatherings.count == 0 {
                    startIndex = 4
                } else {
                    startIndex = 3 + viewModel.myGatherings.count
                }
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.pendingGatherings.count {
                    let gathering = viewModel.pendingGatherings[gatheringIndex]
                    if let user = viewModel.user {
                        if let masterUser = viewModel.masterUsers[gathering.gatheringMaster] {
                            cell.selectionStyle = .default
                            cell.configure(with: gathering, with: user, with: masterUser)
                        } else {
                            viewModel.fetchMasterUser(masterId: gathering.gatheringMaster)
                        }
                    }
                }
                return cell
            }
        case .myGatheringEmptyState:
            if let cell: EmptyStateTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "가입된 소모임이 없습니다")
                return cell
            }
        case .pendingGatheringEmptyState:
            if let cell: EmptyStateTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "가입대기중인 소모임이 없습니다")
                return cell
            }
        case .userGatheringHeader:
            if let cell: SectionTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "\(viewModel.user?.nickname ?? "")의 소모임", count: viewModel.userGatherings.count)
                return cell
            }
        case .userGatherings:
            if let cell: GatheringTVCell = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 2
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.userGatherings.count {
                    let gathering = viewModel.userGatherings[gatheringIndex]
                    if let user = viewModel.user {
                        if let masterUser = viewModel.masterUsers[gathering.gatheringMaster] {
                            cell.selectionStyle = .default
                            cell.configure(with: gathering, with: user, with: masterUser)
                        } else {
                            viewModel.fetchMasterUser(masterId: gathering.gatheringMaster)
                        }
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension ProfileVC: ProfileDelegate {
    func reloadProfileData() {
        viewModel.loadUser(user: UserManager.shared.getUserUid())
    }
    func editProfileBtnDidTap() {
        self.viewModel.editProfileBtnDidTap()
        
    }
}

extension ProfileVC: CustomNavigationDelegate {
    func smallRightBtnDidTap() {
        switch viewModel.profileType {
        case .myProfile:
            self.viewModel.settingBtnDidTap()
        case .userProfile:
            presentActionSheet()
        }
    }
    
    func backBtnDidTap() {
        self.viewModel.backBtnDidTap()
    }
    
}
