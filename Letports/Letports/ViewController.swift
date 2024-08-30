//
//  ViewController.swift
//  Letports
//
//  Created by mosi on 8/5/24.
//

import UIKit

class viewController: UIViewController {
		
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	// MARK: - setupUI
	private func setupUI() {
		self.view.backgroundColor = .lp_background_white
	}
	
}

extension viewController: CustomNavigationDelegate {
	func smallRightBtnDidTap() {
	}
}

