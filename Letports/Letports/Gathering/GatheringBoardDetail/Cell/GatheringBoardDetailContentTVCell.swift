//
//  GatheringBoardDetailProfileTableViewCell.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit

final class GatheringBoardDetailContentTVCell: UITableViewCell {
	
	private let titleLabel: UILabel = {
		let lb = UILabel()
		lb.text = "아니 이거 맞냐?"
		lb.textColor = .black
		lb.font = .systemFont(ofSize: 18, weight: .semibold)
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let contentTextView: UITextView = {
		let tv = UITextView()
		tv.backgroundColor = .lp_white
		tv.layer.cornerRadius = 10
		tv.isUserInteractionEnabled = false
		tv.font = .systemFont(ofSize: 16)
		tv.textColor = .black
		tv.isScrollEnabled = false
		tv.textContainerInset = UIEdgeInsets(top: 50, left: 16, bottom: 16, right: 16)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.text = """
내나이 1989년생 35살
김 감독은 나를 풀타임을 뛰란다
근데 힘들어 죽겠음
집에 가고싶다
원두재 영입해줘..... 나 죽어

서울 - 스완지 - 선더랜드 - 뉴캐슬 - 마요르카 - 서울

우승은 스완지에서만 해봤을뿐

우승도 하고싶당

손흥민 서울로 와서 증명해라

내가 허락함
"""
		return tv
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - setupUI()
	private func setupUI() {
		self.contentView.backgroundColor = .lp_background_white
		[contentTextView, titleLabel].forEach {
			self.contentView.addSubview($0)
		}
		NSLayoutConstraint.activate([
			contentTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			contentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
			
			titleLabel.topAnchor.constraint(equalTo: contentTextView.topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor, constant: -16)
		])
	}
}
