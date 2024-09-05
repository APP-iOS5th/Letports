//
//  ProfileVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//
import UIKit
import Combine
import Kingfisher

protocol SettingDelegate: AnyObject {
    func buttonDidTap(cellType: SettingCellType)
    func toggleDidtap()
}

class SettingVC: UIViewController {
    private var viewModel: SettingVM
    
    init(viewModel: SettingVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var navigationView: CustomNavigationView = {
        let view = CustomNavigationView(isLargeNavi: .small, screenType: .smallSetting)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.isScrollEnabled = false
        tv.register(cellClass: SettingSectionTVCell.self)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .lp_background_white
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .lp_background_white
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        
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

    private func configureCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SettingSectionTVCell = tableView.loadCell(indexPath: indexPath) else {
            return UITableViewCell()
        }
    
        let cellType = viewModel.getCellTypes()[indexPath.row]
        cell.configure(cellType: cellType)
        cell.delegate = self
        return cell
    }
}

extension SettingVC: CustomNavigationDelegate {
    func backBtnDidTap() {
        viewModel.backToProfile()
    }
}

extension SettingVC: SettingDelegate {
    func toggleDidtap() {
        viewModel.notificationUpdate()
    }
    
    func buttonDidTap(cellType: SettingCellType) {
        viewModel.buttonAction(cellType: cellType)
    }
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(for: indexPath)
    }
}
