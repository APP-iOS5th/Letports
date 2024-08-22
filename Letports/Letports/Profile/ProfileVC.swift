//
//  ProfileVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit
import Combine
import Kingfisher

class ProfileVC: UIViewController {
    private var viewModel: ProfileVM
    private var cancellables: Set<AnyCancellable> = []
    private let cellHeight: CGFloat = 70.0
    
    weak var coordinator: ProfileCoordinator?
    
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
                         GatheringTVCell.self)
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
            navigationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 90),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    private func bindViewModel() {
        Publishers.CombineLatest3(
            viewModel.$user,
            viewModel.$myGatherings,
            viewModel.$pendingGatherings
        )
        .sink { [weak self] (user, myGathering, pendingGathering) in
            self?.handleUpdates(user: user, myGathering: myGathering, pendingGathering: pendingGathering)
        }
        .store(in: &cancellables)
    }
    
    private func handleUpdates(user: User?, myGathering: [Gathering], pendingGathering: [Gathering]) {
        tableView.reloadData()
    }
    
    @objc private func editProfile() {
        print("눌림")
        guard let user = viewModel.user else { return }
        coordinator?.showEditProfile(user: user)
    }
    
    
}


extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellType = viewModel.getCellTypes()[indexPath.row]
        
        // profile, myGatherings, pendingGatherings 셀만 선택 가능하도록 설정
        switch cellType {
        case .profile, .myGatherings, .pendingGatherings:
            return indexPath // 선택 가능
        default:
            return nil // 선택 불가
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = viewModel.getCellTypes()[indexPath.row]

        switch cellType {
        case .myGatherings:
            // 셀 간 간격을 추가하는 방법
            cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            cell.contentView.backgroundColor = .clear

        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .profile:
            return 100.0
        case .myGatheringHeader:
            return 50.0
        case .myGatherings:
            return 80.0
        case .pendingGatheringHeader:
            return 50.0
        case .pendingGatherings:
            return 80.0 
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .profile:
            if let cell: ProfileTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.backgroundColor = .lp_background_white
                cell.setEditButtonAction(target: self, action: #selector(editProfile))
                cell.configure(with: viewModel.user!)
                return cell
            }
        case .myGatheringHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "내 소모임")
                cell.backgroundColor = .lp_background_white
                return cell
            }
        case .myGatherings:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.backgroundColor = .lp_background_white
                let startIndex = 2
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.myGatherings.count {
                    let gathering = viewModel.myGatherings[gatheringIndex]
                    cell.configure(with: gathering)
                }
                return cell
            }
        case .pendingGatheringHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.backgroundColor = .lp_background_white
                cell.configure(withTitle: "가입 대기중 소모임")
                return cell
            }
        case .pendingGatherings:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.backgroundColor = .lp_background_white
                let startIndex = 2 + viewModel.myGatherings.count + 1
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.pendingGatherings.count {
                    let gathering = viewModel.pendingGatherings[gatheringIndex]
                    cell.configure(with: gathering)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

extension ProfileVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        
    }
}
