//
//  BoaderEditorVC.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import UIKit

class BoaderEditorVC: UIViewController {
    private(set) lazy var navigationView: CustomNavigationView = {
        let cnv = CustomNavigationView(isLargeNavi: .small,
                                       screenType: .smallBoardEditor(btnName: .write, isUpload: true))
        
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.registersCell(cellClasses: BoaderEditorTitleTVCell.self,
                          BoaderEditorContentTVCell.self,
                          BoaderEditorPhotoTVCell.self)
        
        tv.separatorStyle = .none
        tv.backgroundColor = .lp_background_white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var viewModel: BoaderEditorVM
    
    init(viewModel: BoaderEditorVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    //MARK: - Setup
    private func setupUI() {
        self.view.backgroundColor = .lp_background_white
        
        [navigationView, tableView].forEach {
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
}

extension BoaderEditorVC: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        
    }
    
    func sportsSelectButtonDidTap() {
        
    }
    
    func backButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension BoaderEditorVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.viewModel.getCellTypes()[indexPath.row] {
            
        case .title:
            if let cell: BoaderEditorTitleTVCell = tableView.loadCell(indexPath: indexPath) {
                return cell
            }
        case .content:
            if let cell: BoaderEditorContentTVCell = tableView.loadCell(indexPath: indexPath) {
                return cell
            }
        case .photo:
            if let cell: BoaderEditorPhotoTVCell = tableView.loadCell(indexPath: indexPath) {
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
}


#Preview() {
    BoaderEditorVC(viewModel: BoaderEditorVM())
}
