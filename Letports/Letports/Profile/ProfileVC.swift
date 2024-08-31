

import UIKit
import FirebaseAuth
import Combine
import Kingfisher


protocol ProfileDelegate: AnyObject {
    func EditProfileBtnDidTap()
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
        let btnName: NaviButtonType
        let view = CustomNavigationView(isLargeNavi: .large, screenType: .largeProfile(btnName: .gear))
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
        Publishers.Merge4(
            viewModel.$user.map{ _ in ()},
            viewModel.$myGatherings.map{ _ in ()},
            viewModel.$pendingGatherings.map{ _ in ()},
            viewModel.$masterUsers.map { _ in ()}
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (_) in
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)
    }
    
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellType = viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .profile, .myGatherings, .pendingGatherings:
            return indexPath
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .profile:
            return 120.0
        case .myGatheringHeader, .pendingGatheringHeader:
            return 40.0
        case .myGatherings, .pendingGatherings, .myGatheringEmptyState, .pendingGatheringEmptyState:
            return 100.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .profile:
            if let cell: ProfileTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                if let user = viewModel.user {
                    cell.configure(user:user)
                }
                return cell
            }
        case .myGatheringHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title:"내 소모임")
                return cell
            }
        case .myGatherings:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 2
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.myGatherings.count {
                    let gathering = viewModel.myGatherings[gatheringIndex]
                    if let user = viewModel.user {
                        if let masterUser = viewModel.masterUsers[gathering.gatheringMaster] {
                            cell.configure(with:gathering, with: user, with: masterUser)
                        } else {
                            viewModel.fetchMasterUser(masterId: gathering.gatheringMaster) // 마스터 사용자 정보 가져오기
                        }
                    }
                }
                return cell
            }
        case .pendingGatheringHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title:"가입 대기중 소모임")
                return cell
            }
        case .pendingGatherings:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
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
                            cell.configure(with:gathering, with: user, with: masterUser)
                        } else {
                            viewModel.fetchMasterUser(masterId: gathering.gatheringMaster) // 마스터 사용자 정보 가져오기
                        }
                    }
                }
                return cell
            }
        case .myGatheringEmptyState:
            if let cell: EmptyStateTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "가입된 소모임이 없습니다")
                return cell
            }
        case .pendingGatheringEmptyState:
            if let cell: EmptyStateTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "가입대기중인 소모임이 없습니다")
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension ProfileVC: ProfileDelegate {
    func EditProfileBtnDidTap() {
        self.viewModel.EditProfileBtnDidTap()
    }
}

extension ProfileVC: CustomNavigationDelegate {
    func smallRightBtnDidTap() {
        self.viewModel.settingButtonTapped()
    }
}
