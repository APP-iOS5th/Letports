//
//  HomeVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit
import Combine
import Kingfisher

extension HomeVC: HomeProfileTVCellDelegate, YoutubeThumbnailTVCellDelegate, RecommendGatheringListsDelegate {
    func didTapRecommendGathering(gatheringUID: String) {
        viewModel.pushGatheringDetailController(gatheringUID: gatheringUID)
    }
    
    func didTapYoutubeThumbnail(at index: Int) {
        guard index < viewModel.latestYoutubeVideos.count else { return }
        let video = viewModel.latestYoutubeVideos[index]
        viewModel.presentURLController(with: video.videoURL)
    }
    
    func didTapSNSButton(url: URL) {
        viewModel.presentURLController(with: url)
    }
}

class HomeVC: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var navigationView: CustomNavigationView = {
        let cnv = CustomNavigationView(isLargeNavi: .large, screenType: .largeHome)
        
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
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
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.registersCell(cellClasses: TitleTVCell.self,
                         HomeProfileTVCell.self,
                         YoutubeThumbnailTVCell.self,
                         RecommendGatheringTVCell.self)
        return tv
    }()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //UISetting
    func setupUI() {
        view.backgroundColor = .lp_background_white
        tableView.backgroundColor = .lp_background_white
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        
        tableView.refreshControl = refreshControl
        tableView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //데이터 바인딩
    private func bindViewModel() {
        Publishers.CombineLatest3(viewModel.$team,
                                  viewModel.$latestYoutubeVideos,
                                  viewModel.$recommendGatherings)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (team, latestYoutubeVideos, gatherings) in
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)
        
        UserManager.shared.$currentUser
            .sink { [weak self] _ in
                self?.viewModel.getTeamData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshData() {
        performRefresh()
    }
    
    private func performRefresh() {
        self.viewModel.getTeamData()
        self.refreshControl.endRefreshing()
    }
    
    func reloadTeamData() {
        self.viewModel.getTeamData()
    }
}

extension HomeVC: CustomNavigationDelegate {
    func sportsSelectBtnDidTap() {
        viewModel.presentTeamChangeContorller()
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = self.viewModel.getCellTypes()[indexPath.row]
        switch cellType {
        case .profile:
            return 120
        case .latestVideoTitleLabel:
            return UITableView.automaticDimension
        case .youtubeThumbnails:
            return UITableView.automaticDimension
        case .recommendGatheringTitleLabel:
			return UITableView.automaticDimension
        case .recommendGatheringLists:
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getCellTypes()[indexPath.row] {
        case .profile:
            if let cell: HomeProfileTVCell = tableView.loadCell(indexPath: indexPath) {
                if let team = viewModel.team {
                    cell.delegate = self
                    cell.configure(with: team)
                }
                return cell
            }
        case .latestVideoTitleLabel:
            if let cell: TitleTVCell = tableView.loadCell(indexPath: indexPath) {
                if let teamName = viewModel.team?.teamName {
                    cell.configure(withTitle: "\(teamName)의 최신 영상")
                }
                return cell
            }
        case .youtubeThumbnails:
            if let cell: YoutubeThumbnailTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configure(with: viewModel.latestYoutubeVideos)
                return cell
            }
        case .recommendGatheringTitleLabel:
            if let cell: TitleTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configure(withTitle: "추천 소모임")
                return cell
            }
        case .recommendGatheringLists:
            if let cell: RecommendGatheringTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.delegate = self
                cell.configure(gatherings: viewModel.recommendGatherings)
                
                return cell
            }
        }
        return UITableViewCell()
    }
}
