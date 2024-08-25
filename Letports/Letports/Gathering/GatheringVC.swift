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
        //tv.delegate = self
        //tv.dataSource = self
        tv.separatorStyle = .none
        tv.registersCell(cellClasses: SectionTVCell.self, GatheringTVCell.self)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .lp_background_white
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .lpBackgroundWhite
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$recommendGatherings
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$gatheringLists
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension GatheringVC: CustomNavigationDelegate {
    
}



//extension GatheringVC: UITableViewDelegate, UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.getCellCount()
//    }
//
//    func tableView(_ tableView: UITableView, willSelectRowAt: IndexPath) -> IndexPath? {
//        let cellType = viewModel.getCellTypes()[indexPath.row]
//        
//        switch cellType {
//        case .recommendGatherings, .GatheringLists:
//            return indexPath
//        default:
//            return nil
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cellType = viewModel.getCellTypes()[indexPath.row]
//        
//        switch cellType {
//        case .GatheringLists:
//            cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//            cell.contentView.backgroundColor = .clear
//
//        default:
//            break
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cellType = self.viewModel.getCellTypes()[indexPath.row]
//        switch cellType {
//        case .recommendGatheringHeader:
//            return 100.0
//        case .recommendGatherings:
//            return 80.0
//        case .GatheringListHeader:
//            return 100.0
//        case .GatheringLists:
//            return 80
//        }
//    }
        
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch self.viewModel.getCellTypes()[indexPath.row] {
//        case .recommendGatheringHeader:
//            if let cell:
//                case.
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cellType = self.viewModel.
//    }
//}
