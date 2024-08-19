//
//  ViewController.swift
//  Letports
//
//  Created by mosi on 8/5/24.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var navigationView: CustomNavigationView = {
        
        let btnName: NaviButtonType
        
        if UserManager.shared.isLoggedIn {
            switch UserManager.shared.userRole {
            case .admin:
                btnName = .gear
            case .member:
                btnName = .ellipsis
            case .guest:
                btnName = .empty
            }
        } else {
            btnName = .empty
        }
        
        let view = CustomNavigationView(isLargeNavi: .small,
                                        screenType: .smallGathering(gatheringName: "안녕안녕 영어모임",
                                                                    btnName: btnName)
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        navigationView.delegate = self
        self.view.addSubview(navigationView)
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        self.view.backgroundColor = UIColor("#BBBBBB", alpha: 1.0)
        self.view.backgroundColor = .lp_background_white
    

    }
}

extension ViewController: CustomNavigationDelegate {
    func smallRightButtonDidTap() {
        
    }
}
