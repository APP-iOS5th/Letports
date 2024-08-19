//
//  ProfileVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit
import Combine

class ProfileVC: UIViewController {
    
    weak var coordinator: ProfileCoordinator?
    
    private let viewModel = ProfileVM()
    private var cancellables = Set<AnyCancellable>()
    private let cellHeight: CGFloat = 80.0
    
    private lazy var navigationView: CustomNavigationView = {
        let btnName: NaviButtonType
        let view = CustomNavigationView(isLargeNavi: .large, screenType: .largeProfile(btnName: .gear))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileView: ProfileView = {
        let view = ProfileView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lp_background_white
        return view
    }()
    
    private lazy var myGathering: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "내 소모임"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var myGatheringTV: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(GatheringCell.self, forCellReuseIdentifier: "GatheringListCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var pendingGathering: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "가입 대기 중인 소모임"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pendingGatheringTV: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(GatheringCell.self, forCellReuseIdentifier: "GatheringListCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    //기본 테이블뷰 높이 설정
    private lazy var myGatheringTVHeightConstraint: NSLayoutConstraint = {
        return myGatheringTV.heightAnchor.constraint(equalToConstant: 200)
    }()
    
    private lazy var pendingGatheringTVHeightConstraint: NSLayoutConstraint = {
        return pendingGatheringTV.heightAnchor.constraint(equalToConstant: 200)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        updateTVHeight()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .lp_background_white
        view.addSubview(navigationView)
        view.addSubview(profileView)
        view.addSubview(myGathering)
        view.addSubview(myGatheringTV)
        view.addSubview(pendingGathering)
        view.addSubview(pendingGatheringTV)
        
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 90),
            
            
            profileView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 20),
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            profileView.widthAnchor.constraint(equalToConstant: 361),
            profileView.heightAnchor.constraint(equalToConstant: 100),
            
            
            myGathering.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 20),
            myGathering.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myGathering.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            myGatheringTV.topAnchor.constraint(equalTo: myGathering.bottomAnchor, constant: 10),
            myGatheringTV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myGatheringTV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myGatheringTV.widthAnchor.constraint(equalToConstant: 361),
            myGatheringTVHeightConstraint,
            
            
            pendingGathering.topAnchor.constraint(equalTo: myGatheringTV.bottomAnchor, constant: 20),
            pendingGathering.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pendingGathering.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            pendingGatheringTV.topAnchor.constraint(equalTo: pendingGathering.bottomAnchor, constant: 10),
            pendingGatheringTV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pendingGatheringTV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pendingGatheringTVHeightConstraint,
        ])
    }
    
    private func bindViewModel() {
        viewModel .$user
            .sink { [weak self] user in
                self?.profileView.configure(with: user)
            }
            .store(in: &cancellables)
        
        viewModel .$myGatherings
            .sink { [weak self] _ in
                self?.myGatheringTV.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel .$pendingGatherings
            .sink { [weak self] _ in
                self?.pendingGatheringTV.reloadData()
            }
            .store(in: &cancellables)
    }
    
    //셀의 갯수에 따라 테이블뷰의 높이 변경
    private func updateTVHeight() {
        let myGatheringsCount = viewModel.myGatherings.count
        let pendingGatheringsCount = viewModel.pendingGatherings.count
        
        myGatheringTVHeightConstraint.constant = (myGatheringsCount == 0) ? 200 : cellHeight  * CGFloat(myGatheringsCount)
        pendingGatheringTVHeightConstraint.constant = (pendingGatheringsCount == 0) ? 200 : cellHeight  * CGFloat(pendingGatheringsCount)
        
        view.layoutIfNeeded()
    }
}


extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myGatheringTV {
            return viewModel.myGatherings.count
        } else if tableView == pendingGatheringTV {
            return viewModel.pendingGatherings.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatheringListCell", for: indexPath) as? GatheringCell else {
            return UITableViewCell()
        }
        
        let gathering: Gathering
        if tableView == myGatheringTV {
            gathering = viewModel.myGatherings[indexPath.row]
        } else {
            gathering = viewModel.pendingGatherings[indexPath.row]
        }
        
        cell.configure(with: gathering)
        return cell
    }
}

extension ProfileVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        
    }
}
