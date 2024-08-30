//
//  GatherSettingVC.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import UIKit
import Combine

protocol ManageViewPendingDelegate: AnyObject {
    func denyJoinGathering()
    func apporveJoinGathering()
}
protocol ManageViewJoinDelegate: AnyObject {
    func cancelAction()
    func expelGathering()
}

class GatherSettingVC: UIViewController {
    
    private var viewModel: GatherSettingVM
    private var cancellables: Set<AnyCancellable> = []
    private var manageUserView: ManageUserView?
    
    init(viewModel: GatherSettingVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var navigationView: CustomNavigationView = {
        let btnName: NaviButtonType
        let view = CustomNavigationView(isLargeNavi: .small, screenType: .smallGatheringSetting(btnName: .update))
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
                         GatherDeleteTVCell.self)
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
        Publishers.CombineLatest3(
            viewModel.$gathering,
            viewModel.$pendingGatheringMembers,
            viewModel.$joiningGatheringMembers
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (gathering, pendingMembers, joiningMembers) in
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)
    }
    
    private func showUserView<T: UIView>(existingView: inout T?, user: GatheringMember, gathering: Gathering, joinDelegate: ManageViewJoinDelegate?, pendingDelegate: ManageViewPendingDelegate?) {
        if existingView == nil {
            let manageUserView = ManageUserView()
            manageUserView.joindelegate = joinDelegate
            manageUserView.pendingdelegate = pendingDelegate
            manageUserView.configure(with: user, with: gathering)
            self.view.addSubview(manageUserView)
            NSLayoutConstraint.activate([
                manageUserView.topAnchor.constraint(equalTo: view.topAnchor),
                manageUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                manageUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                manageUserView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}

extension GatherSettingVC: ManageViewJoinDelegate, ManageViewPendingDelegate {
    func cancelAction() {
        self.viewModel.cancel()
    }
    
    func expelGathering() {
        self.viewModel.expelUser()
    }
    
    func denyJoinGathering() {
        self.viewModel.denyUser()
    }
    
    func apporveJoinGathering() {
        self.viewModel.approveUser()
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
        case .pendingGatheringUser, .joiningGatheringUser:
            return 80.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .pendingGatheringUser:
            let startIndex = 1
            let userIndex = indexPath.row - startIndex
            if userIndex < viewModel.pendingGatheringMembers.count {
                let user = viewModel.pendingGatheringMembers[userIndex]
                if let gathering = viewModel.gathering {
                    showUserView(existingView: &manageUserView, user: user, gathering: gathering, joinDelegate: nil,
                                 pendingDelegate: self)
                }
            }
        case .joiningGatheringUser:
            let startIndex = 2 + viewModel.pendingGatheringMembers.count
            let userIndex = indexPath.row - startIndex
            if userIndex < viewModel.joiningGatheringMembers.count {
                let user = viewModel.joiningGatheringMembers[userIndex]
                if let gathering = viewModel.gathering {
                    showUserView(existingView: &manageUserView, user: user, gathering: gathering, joinDelegate: self,
                                 pendingDelegate: nil)
                }
            }
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
                cell.configure(withTitle: "가입 신청 인원")
                return cell
            }
        case .pendingGatheringUser:
            if let cell: GatherUserTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 1
                let userIndex = indexPath.row - startIndex
                if userIndex < viewModel.pendingGatheringMembers.count {
                    let user = viewModel.pendingGatheringMembers[userIndex]
                    cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
                    cell.configure(with: user)
                }
                return cell
            }
        case .joiningGatheringUserTitle:
            if let cell: GatherSectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "가입 중 인원")
                return cell
            }
        case .joiningGatheringUser:
            if let cell: GatherUserTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 2 + viewModel.pendingGatheringMembers.count
                let userIndex = indexPath.row - startIndex
                if userIndex < viewModel.joiningGatheringMembers.count {
                    let user = viewModel.joiningGatheringMembers[userIndex]
                    cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
                    cell.configure(with: user)
                }
                return cell
            }
        case .settingTitle:
            if let cell: GatherSectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "설정")
                return cell
            }
        case .deleteGathering:
            if let cell: GatherDeleteTVCell  = tableView.loadCell(indexPath: indexPath) {
                return cell
            }
        }
        return UITableViewCell()
    }
}
