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
    func toggleDidTap()
    func buttonDidTap(cellType: SettingCellType)
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
        checkNotificationPermission()
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
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self.viewModel.notificationToggleState = true
                case .denied, .notDetermined:
                    self.viewModel.notificationToggleState = false
                @unknown default:
                    self.viewModel.notificationToggleState = false
                }
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic) //
            }
        }
    }
    
}

extension SettingVC: CustomNavigationDelegate {
    func backBtnDidTap() {
        viewModel.backToProfile()
    }
}

extension SettingVC: SettingDelegate {
    
    func toggleDidTap() {
        if viewModel.notificationToggleState {
            openAppSettings()
        } else {
            requestNotificationPermission()
        }
    }
    
    
    func buttonDidTap(cellType: SettingCellType) {
        switch cellType {
        case .logout:
            self.showAlert(title: "알림", message: "정말로 로그아웃하시겠습니까?", confirmTitle: "로그아웃", cancelTitle: "취소") {
                self.viewModel.logout()
            }
        case .exit:
            self.showAlert(title: "알림", message: "정말로 회원탈퇴 하시겠습니까? 모든 소모임, 게시글은 삭제되며 복구할수 없습니다.", confirmTitle: "로그아웃", cancelTitle: "취소") {
                self.viewModel.exit()
            }
        default:
            viewModel.buttonAction(cellType: cellType)
        }
    }
    
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.viewModel.notificationToggleState = granted
                self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
            }
        }
    }
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getSectionCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getRowCount(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModel.getCellType(for: indexPath)
        if let cell: SettingSectionTVCell = tableView.loadCell(indexPath: indexPath){
            cell.configure(cellType: cellType, notificationState: viewModel.notificationToggleState)
            cell.delegate = self
            return cell
            
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getSectionTitle(for: section)
    }
}
