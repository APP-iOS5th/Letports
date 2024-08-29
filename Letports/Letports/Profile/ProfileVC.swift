

import UIKit
import FirebaseAuth
import Combine
import Kingfisher


protocol ProfileDelegate: AnyObject {
    func didTapEditProfileButton()
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
                         SeparatorTVCell.self)
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
        Publishers.CombineLatest3(
            viewModel.$user,
            viewModel.$myGatherings,
            viewModel.$pendingGatherings
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (user, myGathering, pendingGathering) in
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
        case .profile:
            return indexPath
        case .myGatherings:
            return indexPath
        case .pendingGatherings:
            return indexPath
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .myGatherings:
            let startIndex = 2
            let userIndex = indexPath.row - startIndex
            if userIndex < viewModel.myGatherings.count {
                let user = viewModel.myGatherings[userIndex]
                self.viewModel.gatheringCellTapped(gatheringUID: user.gatheringUid)
            }
        case .pendingGatherings:
            let startIndex = 3 + viewModel.myGatherings.count
            let userIndex = indexPath.row - startIndex
            if userIndex < viewModel.pendingGatherings.count {
                let user = viewModel.pendingGatherings[userIndex]
                self.viewModel.gatheringCellTapped(gatheringUID: user.gatheringUid)
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
        case .myGatheringHeader:
            return 40.0
        case .myGatherings:
            return 100.0
        case .pendingGatheringHeader:
            return 40.0
        case .pendingGatherings:
            return 100.0
        case .myGatheringSeparator:
            return 100.0
        case .pendingGatheringSeparator:
            return 100.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .profile:
            if let cell: ProfileTVCell  = tableView.loadCell(indexPath: indexPath) {
                if let user = viewModel.user {
                    cell.delegate = self
                    cell.configure(with: viewModel.user!)
                }
                return cell
            }
        case .myGatheringHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "내 소모임")
                return cell
            }
        case .myGatherings:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 2
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.myGatherings.count {
                    let gathering = viewModel.myGatherings[gatheringIndex]
                    if let user = viewModel.user {
                        viewModel.loadMasterUser(with: gathering.gatheringMaster)
                            .sink { completion in
                                switch completion {
                                case .finished:
                                    break // 작업이 성공적으로 완료된 경우
                                case .failure(let error):
                                    print("Error loading master user: \(error.localizedDescription)")
                                }
                            } receiveValue: { masterUser in
                                DispatchQueue.main.async {
                                    cell.configure(with: gathering, with: user, with: masterUser)
                                }
                            }
                            .store(in: &cancellables)
                    }
                }
                return cell
            }
        case .pendingGatheringHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "가입 대기중 소모임")
                return cell
            }
        case .pendingGatherings:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = viewModel.myGatherings.count + 3
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.pendingGatherings.count {
                    let gathering = viewModel.pendingGatherings[gatheringIndex]
                    if let user = viewModel.user {
                        viewModel.loadMasterUser(with: gathering.gatheringMaster)
                            .sink { completion in
                                switch completion {
                                case .finished:
                                    break // 작업이 성공적으로 완료된 경우
                                case .failure(let error):
                                    print("Error loading master user: \(error.localizedDescription)")
                                }
                            } receiveValue: { masterUser in
                                DispatchQueue.main.async {
                                    cell.configure(with: gathering, with: user, with: masterUser)
                                }
                            }
                            .store(in: &cancellables)
                    }
                }
                return cell
            }
        case .myGatheringSeparator:
            if let cell: SeparatorTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "가입된 소모임이 없습니다")
                return cell
            }
        case .pendingGatheringSeparator:
            if let cell: SeparatorTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "가입대기중인 소모임이 없습니다")
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension ProfileVC: ProfileDelegate {
    func didTapEditProfileButton() {
        self.viewModel.profileEditButtonTapped()
    }
}

extension ProfileVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        self.viewModel.settingButtonTapped()
    }
}
