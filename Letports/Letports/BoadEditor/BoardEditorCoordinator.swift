//
//  BoardEditorCoordinator.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import Foundation
import UIKit

class BoardEditorCoordinator: Coordinator {
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init() {
        self.navigationController = .init()
    }
    
    func start() {
        let viewModel = BoardEditorVM()
        let vc = BoardEditorVC(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}

