//
//  BoardTV.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

class BoardTV: UITableViewController {
	
	private let boards: [Board]
	
	init(boards: [Board]) {
		self.profiles = profiles
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 16
		layout.minimumInteritemSpacing = 16
		layout.itemSize = CGSize(width: 50, height: 100)
		super.init(frame: .zero, collectionViewLayout: layout)
		setupView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView
	}
	
	private func setupView() {
		translatesAutoresizingMaskIntoConstraints = false
		showsHorizontalScrollIndicator = false
		backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		dataSource = self
		register(GatheringDetailProfileCVC.self, forCellWithReuseIdentifier: "Cell")
	}
}

// MARK: - Table view data source
extension GatheringDetailProfileCV: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return profiles.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GatheringDetailProfileCVC
		cell.configure(profile: profiles[indexPath.item])
		return cell
	}
