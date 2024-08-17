//
//  BoarderEditorCoordinator.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import Foundation
import UIKit

class BoarderEditorCoordinator: Coordinator {
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init() {
        self.navigationController = .init()
    }
    
    func start() {
        let viewModel = BoarderEditorVM()
        let vc = BoarderEditorVC(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}

