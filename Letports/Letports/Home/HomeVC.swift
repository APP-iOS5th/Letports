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
    func didTapRecommendGathering() {
        viewModel.pushGatheringDetailController()
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
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.registersCell(cellClasses: TitleTVCell.self, HomeProfileTVCell.self, YoutubeThumbnailTVCell.self, RecommendGatheringTVCell.self)
        
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
    
    //MARK: -Methods
    
    
    
    //UISetting
    func setupUI() {
        view.backgroundColor = .lpBackgroundWhite
        
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        
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
    
    
    
    //        lazy var homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHomeTap))
    //        homeURLSV.addGestureRecognizer(homeTapGesture)
    //        homeURLSV.isUserInteractionEnabled = true
    //
    //        lazy var instaTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInstaTap))
    //        instagramURLSV.addGestureRecognizer(instaTapGesture)
    //        instagramURLSV.isUserInteractionEnabled = true
    //
    //        lazy var youtubeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleYoutubeTap))
    //        youtubeURLSV.addGestureRecognizer(youtubeTapGesture)
    //        youtubeURLSV.isUserInteractionEnabled = true
    
    //첫번째 썸네일 탭 제스쳐
    //        let firstThumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail1Tap))
    //        firstThumbnailSV.addGestureRecognizer(firstThumbnailTapGesture)
    //        firstThumbnailSV.isUserInteractionEnabled = true
    //
    //        //두번째 썸네일
    //        let secondThumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail2Tap))
    //        secondThumbnailSV.addGestureRecognizer(secondThumbnailTapGesture)
    //        secondThumbnailSV.isUserInteractionEnabled = true
    
    //데이터 바인딩
    private func bindViewModel() {
        Publishers.CombineLatest3(viewModel.$team, viewModel.$latestYoutubeVideos, viewModel.$gatherings)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (team, latestYoutubeVideos, gatherings) in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}
    
    extension HomeVC: CustomNavigationDelegate {
        
    }
    
    extension HomeVC: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.getCellCount()
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let cellType = self.viewModel.getCellTypes()[indexPath.row]
            switch cellType {
            case .profile:
                return 110
            case .latestVideoTitleLabel:
                return 60
            case .youtubeThumbnails:
                return 160
            case .recommendGatheringTitleLabel:
                return 60
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
                        cell.team = team
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
                    cell.configure(withTitle: "추천 소모임🔥")
                    
                    return cell
                }
            case .recommendGatheringLists:
                if let cell: RecommendGatheringTVCell = tableView.loadCell(indexPath: indexPath) {
                    cell.delegate = self
                    print("뷰모델입니다 \(viewModel.gatherings)")
                    //cell.configure(gatherings: viewModel.gatherings)
                    return cell
                }
            }
            return UITableViewCell()
        }
    }
