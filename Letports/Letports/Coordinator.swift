//
//  Coordinator.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func start()
}
