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
    
    private lazy var profileView: ProfileView = {
        let view = ProfileView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.setEditButtonAction(target: self, action: #selector(editProfile))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lp_white
        return view
    }()
    
    
    private lazy var myGatheringTitle: UILabel = {
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
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.backgroundColor = .lp_white
        tv.register(GatheringCell.self, forCellReuseIdentifier: "GatheringListCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var pendingGatheringTitle: UILabel = {
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
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.backgroundColor = .lp_background_white
        tv.register(GatheringCell.self, forCellReuseIdentifier: "GatheringListCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    //기본 테이블뷰 높이 설정
    private lazy var myGatheringTVHeightConstraint: NSLayoutConstraint = {
        return myGatheringTV.heightAnchor.constraint(equalToConstant: 100)
    }()
    
    private lazy var pendingGatheringTVHeightConstraint: NSLayoutConstraint = {
        return pendingGatheringTV.heightAnchor.constraint(equalToConstant: 100)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myGatheringTV.reloadData()
        pendingGatheringTV.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myGatheringTV.reloadData()
        pendingGatheringTV.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .lp_background_white
        [navigationView, profileView, myGatheringTitle, myGatheringTV, pendingGatheringTitle, pendingGatheringTV].forEach {
            self.view.addSubview($0)
        }
        self.navigationController?.isNavigationBarHidden = true
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 90),
            
            profileView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 20),
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            profileView.heightAnchor.constraint(equalToConstant: 100),
            
            myGatheringTitle.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 20),
            myGatheringTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myGatheringTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myGatheringTitle.heightAnchor.constraint(equalToConstant: 19),
            
            myGatheringTV.topAnchor.constraint(equalTo: myGatheringTitle.bottomAnchor, constant: 10),
            myGatheringTV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myGatheringTV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            pendingGatheringTitle.topAnchor.constraint(equalTo: myGatheringTV.bottomAnchor, constant: 20),
            pendingGatheringTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pendingGatheringTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pendingGatheringTitle.heightAnchor.constraint(equalToConstant: 19),
            
            pendingGatheringTV.topAnchor.constraint(equalTo: pendingGatheringTitle.bottomAnchor, constant: 10),
            pendingGatheringTV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pendingGatheringTV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pendingGatheringTV.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor)
        ])
        
    }
    
    private func bindViewModel() {
        viewModel.$user
            .sink { user in
                self.profileView.nickNameLabel.text = user?.nickname
                self.profileView.simpleInfoLabel.text = user?.simpleInfo
                guard let url = URL(string: user?.image ?? "") else {
                    print("Invalid URL")
                    self.profileView.profileIV.image = UIImage(systemName: "person.circle")
                    return
                }
                self.profileView.profileIV.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle"), options: [.transition(.fade(0.2))], completionHandler: { result in
                    switch result {
                    case .success(let value):
                        print("Image fetched successfully: \(value.image)")
                    case .failure(let error):
                        print("Error fetching image: \(error)")
                    }
                })
            }
            .store(in: &cancellables)
        
        viewModel.$myGatherings
            .receive(on: RunLoop.main)
            .sink { [weak self] gatherings in
                self?.myGatheringTV.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$pendingGatherings
            .receive(on: RunLoop.main)
            .sink { [weak self] gatherings in
                self?.pendingGatheringTV.reloadData()
            }
            .store(in: &cancellables)
    }

    @objc private func editProfile() {
        print("눌림")
        guard let user = viewModel.user else { return }
        coordinator?.showEditProfile(user: user)
        
    }
  
    
}


extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100  // Adjust based on your design
    }
    
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
            cell.gatheringName.text = gathering.gatherName
            cell.gatheringInfo.text = gathering.gatherInfo
            cell.gatheringMasterName.text = gathering.gatheringMaster
            cell.createGatheringDate.text = gathering.gatheringCreateDate
            cell.memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
            cell.gatheringIV.kf.setImage(with: URL(string: gathering.gatherImage)!)
            cell.gatheringMasterIV.kf.setImage(with: URL(string: gathering.gatherImage)!)
        } else {
            gathering = viewModel.pendingGatherings[indexPath.row]
            cell.gatheringName.text = gathering.gatherName
            cell.gatheringInfo.text = gathering.gatherInfo
            cell.gatheringMasterName.text = gathering.gatheringMaster
            cell.createGatheringDate.text = gathering.gatheringCreateDate
            cell.memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
            cell.gatheringIV.kf.setImage(with: URL(string: gathering.gatherImage)!)
            cell.gatheringMasterIV.kf.setImage(with: URL(string: gathering.gatheringMaster)!)
        }
        
        
        return cell
    }
    
    
}

extension ProfileVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        
    }
}
