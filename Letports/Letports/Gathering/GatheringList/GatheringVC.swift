//
//  GatheringVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit
import Combine
import Kingfisher

class GatheringVC: UIViewController {
    
    private var viewModel: GatheringVM
    private var cancellables: Set<AnyCancellable> = []
    weak var coordinator: GatheringCoordinator?
    
    init(viewModel: GatheringVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var navigationView: CustomNavigationView = {
        let cnv = CustomNavigationView(isLargeNavi: .large,
                                       screenType: .largeGathering)
        
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.registersCell(cellClasses: SectionTVCell.self, GatheringTVCell.self, EmptyStateTVCell.self)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .lp_background_white
        return tv
    }()
    
    private lazy var floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .large)
        let largePencil = UIImage(systemName: "pencil", withConfiguration: largeConfig)
        button.setImage(largePencil, for: .normal)
        button.tintColor = .lp_white
        button.backgroundColor = .lp_main
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .lpBackgroundWhite
        [navigationView, tableView, floatingButton].forEach {
            self.view.addSubview($0)
        }
        
        self.tableView.refreshControl = self.refreshControl
        self.tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            floatingButton.widthAnchor.constraint(equalToConstant: 60),
            floatingButton.heightAnchor.constraint(equalToConstant: 60),
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func bindViewModel() {
        Publishers.Merge3(
            viewModel.$recommendGatherings.map { _ in () } ,
            viewModel.$gatheringLists.map {_ in () },
            viewModel.$masterUsers.map {_ in () }
        )
        .sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
        .store(in: &cancellables)
        
        UserManager.shared.$selectedTeam
            .sink { [weak self] team in
                self?.viewModel.loadTeam()
            }
            .store(in: &cancellables)
    }
    
    @objc func pullToRefresh(_ sender: UIRefreshControl) {
        UserManager.shared.getTeam { [weak self] result in
            switch result {
            case .success(let team):
                self?.viewModel.loadGatherings(forTeam: team.teamUID)
            case .failure(let error):
                print("getTeam Error \(error)")
            }
        }
    }
    
    func loadGathering() {
        self.viewModel.loadGatherings(forTeam: UserManager.shared.currentUser?.userSportsTeam ?? "")
    }
}

extension GatheringVC: CustomNavigationDelegate {
    func sportsSelectBtnDidTap() {
        viewModel.presentTeamChangeController()
        print("TeamChangeView")
    }
}

extension GatheringVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var startIndex: Int
        switch viewModel.getCellTypes()[indexPath.row] {
        case .recommendGatherings:
            startIndex = 1
            let gatheringIndex = indexPath.row - startIndex
            if gatheringIndex >= 0 && gatheringIndex < viewModel.recommendGatherings.count {
                let (gathering, sports) = viewModel.recommendGatherings[gatheringIndex]
                viewModel.pushGatheringDetailController(gatheringUid: gathering.gatheringUid, teamColor: sports.logoHex)
            }
        case .gatheringLists:
            startIndex = viewModel.recommendGatherings.isEmpty ? 3 : 2 + viewModel.recommendGatherings.count
            let gatheringIndex = indexPath.row - startIndex
            if gatheringIndex >= 0 && gatheringIndex < viewModel.gatheringLists.count {
                let (gathering, sports) = viewModel.gatheringLists[gatheringIndex]
                viewModel.pushGatheringDetailController(gatheringUid: gathering.gatheringUid, teamColor: sports.logoHex)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .recommendGatheringHeader, .gatheringListHeader:
            return 50.0
        case .gatheringLists, .recommendGatherings, .recommendGatheringEmptyState, .gatheringListEmptyState:
            return 110.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .recommendGatheringHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title:"추천 소모임", count: viewModel.recommendGatherings.count)
                return cell
            }
        case .recommendGatherings:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = 1
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.recommendGatherings.count {
                    let (gathering, sports) = viewModel.recommendGatherings[gatheringIndex]
                    if let master = viewModel.masterUsers[gathering.gatheringMaster] {
                        cell.configure(with: gathering, with: sports, with: master)
                    }
                }
                return cell
            }
        case .gatheringListHeader:
            if let cell: SectionTVCell  = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title:"소모임 리스트", count: viewModel.gatheringLists.count)
                return cell
            }
        case .gatheringLists:
            if let cell: GatheringTVCell  = tableView.loadCell(indexPath: indexPath) {
                let startIndex = viewModel.getRecommendGatheringCount() + 2
                let gatheringIndex = indexPath.row - startIndex
                if gatheringIndex < viewModel.gatheringLists.count {
                    let (gathering, sports) = viewModel.gatheringLists[gatheringIndex]
                    if let master = viewModel.masterUsers[gathering.gatheringMaster] {
                        cell.configure(with: gathering, with: sports, with: master)
                    }
                }
                return cell
            }
        case .recommendGatheringEmptyState:
            if let cell: EmptyStateTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "아직 생성된 소모임이 없습니다.")
                return cell
            }
        case .gatheringListEmptyState:
            if let cell: EmptyStateTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(title: "아직 생성된 소모임이 없습니다.")
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: objc 함수
    //소모임 생성 버튼 동작 함수
    @objc private func floatingButtonTapped() {
        viewModel.pushGatheringUploadController()
    }
}
