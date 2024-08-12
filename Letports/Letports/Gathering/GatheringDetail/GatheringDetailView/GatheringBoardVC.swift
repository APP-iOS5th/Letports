//
//  GatheringBoardVC.swift
//  Letports
//
//  Created by Yachae on 8/12/24.
//

import UIKit

class GatheringBoardVC: UIViewController, UITableViewDelegate {
	let tableView = UITableView()
	let data = [
		["전체 항목 1", "전체 항목 2", "전체 항목 3,전체 항목 1", "전체 항목 2", "전체 항목 3,전체 항목 1", "전체 항목 2", "전체 항목 3"],
		["공지 항목 1", "공지 항목 2", "공지 항목 3","공지 항목 1", "공지 항목 2", "공지 항목 3","공지 항목 1", "공지 항목 2", "공지 항목 3"
		 ,"공지 항목 1", "공지 항목 2", "공지 항목 3","공지 항목 1", "공지 항목 2", "공지 항목 3","공지 항목 1", "공지 항목 2", "공지 항목 3"
		 ,"공지 항목 1", "공지 항목 2", "공지 항목 3"],
		["자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3","자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3",
		 "자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3","자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3",
		 "자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3","자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3",
		 "자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3","자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3",
		 "자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3","자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3",
		 "자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3","자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3",
		 "자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3","자유게시판 항목 1", "자유게시판 항목 2", "자유게시판 항목 3"]
	]
	var currentData: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 테이블뷰 설정
		tableView.delegate = self
		tableView.dataSource = self
		tableView.isScrollEnabled = true
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			
		])
		view.addSubview(tableView)
		
		// 초기 데이터 설정
		currentData = data[0]
		
		// 버튼 설정
		let buttonTitles = ["전체", "공지", "자유게시판"]
			let spacing: CGFloat = 8
			var previousButton: UIButton?

			for title in buttonTitles {
				let button = UIButton()
				button.setTitle(title, for: .normal)
				button.setTitleColor(.black, for: .normal)
				button.translatesAutoresizingMaskIntoConstraints = false
				button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
				view.addSubview(button)

				NSLayoutConstraint.activate([
					button.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
					button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
					button.heightAnchor.constraint(equalToConstant: 50)
				])

				if let previousButton = previousButton {
					button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: spacing).isActive = true
				} else {
					button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
				}

				previousButton = button
			}
		}

	@objc func buttonTapped(_ sender: UIButton) {
		currentData = data[sender.tag]
		tableView.reloadData()
	}
}


extension GatheringBoardVC: UITableViewDataSource {
	// 테이블뷰 데이터 소스 및 델리게이트 메서드
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentData.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.text = currentData[indexPath.row]
		return cell
	}
}

#Preview {
	GatheringBoardVC()
}
