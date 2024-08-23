//
//  GatheringVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class GatheringVC: UIViewController {
    
    weak var coordinator: GatheringCoordinator?
    
    private(set) lazy var navigationView: CustomNavigationView = {
        let cnv = CustomNavigationView(isLargeNavi: .large,
                                       screenType: .largeGathering)
        
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lpBackgroundWhite
        
        view.addSubview(navigationView)
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension GatheringVC: CustomNavigationDelegate {
    
}
