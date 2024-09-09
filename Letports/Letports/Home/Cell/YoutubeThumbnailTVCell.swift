//
//  YoutubeThumbnailTVCell.swift
//  Letports
//
//  Created by 홍준범 on 8/27/24.
//

import Foundation
import UIKit

protocol YoutubeThumbnailTVCellDelegate: AnyObject {
	func didTapYoutubeThumbnail(at index: Int)
}

class YoutubeThumbnailTVCell: UITableViewCell {
	
	weak var delegate: YoutubeThumbnailTVCellDelegate?
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 12
		view.backgroundColor = .lp_white
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var thumbnailSV: UIStackView = {
		let sv = UIStackView()
		sv.axis = .horizontal
		sv.alignment = .fill
		sv.distribution = .fillEqually
		sv.spacing = 5
		sv.translatesAutoresizingMaskIntoConstraints = false
		
		return sv
	}()
	
	private lazy var firstThumbnailSV: UIStackView = {
		let sv = UIStackView()
		sv.axis = .vertical
		sv.alignment = .fill
		sv.distribution = .fill
		sv.spacing = 5
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	private lazy var firstThumbnail: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFill
		image.backgroundColor = .lpGray
		image.layer.cornerRadius = 10
		image.clipsToBounds = true
		image.translatesAutoresizingMaskIntoConstraints = false
		
		return image
	}()
	
	lazy var firstThumbnailTitle: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = .lp_Font(.regular, size: 12)
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var secondThumbnailSV: UIStackView = {
		let sv = UIStackView()
		sv.axis = .vertical
		sv.alignment = .fill
		sv.distribution = .fill
		sv.spacing = 5
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()
	
	//썸네일2 이미지
	lazy var secondThumbnail: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFill
		image.backgroundColor = .lpGray
		image.layer.cornerRadius = 10
		image.clipsToBounds = true
		image.translatesAutoresizingMaskIntoConstraints = false
		
		return image
	}()
	
	//썸네일2 제목
	lazy var secondThumbnailTitle: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = .lp_Font(.regular, size: 12)
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.selectionStyle = .none
		setupUI()
	}
	
	private func setupUI() {
		firstThumbnailSV.addArrangedSubview(firstThumbnail)
		firstThumbnailSV.addArrangedSubview(firstThumbnailTitle)
		
		secondThumbnailSV.addArrangedSubview(secondThumbnail)
		secondThumbnailSV.addArrangedSubview(secondThumbnailTitle)
		
		thumbnailSV.addArrangedSubview(firstThumbnailSV)
		thumbnailSV.addArrangedSubview(secondThumbnailSV)
		
		contentView.addSubview(containerView)
		contentView.backgroundColor = .lp_background_white
		
		[thumbnailSV].forEach {
			containerView.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			
			thumbnailSV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
			thumbnailSV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
			thumbnailSV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
			thumbnailSV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
			
			firstThumbnail.heightAnchor.constraint(equalTo: firstThumbnailSV.heightAnchor, multiplier: 0.75),
			firstThumbnailTitle.heightAnchor.constraint(equalToConstant: 32),
			
			secondThumbnail.heightAnchor.constraint(equalTo: secondThumbnailSV.heightAnchor, multiplier: 0.75),
			secondThumbnailTitle.heightAnchor.constraint(equalToConstant: 32)
		])
		
		//첫번째 썸네일 탭 제스쳐
		let firstThumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail1Tap))
		firstThumbnailSV.addGestureRecognizer(firstThumbnailTapGesture)
		firstThumbnailSV.isUserInteractionEnabled = true
		
		//두번째 썸네일
		let secondThumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail2Tap))
		secondThumbnailSV.addGestureRecognizer(secondThumbnailTapGesture)
		secondThumbnailSV.isUserInteractionEnabled = true
	}
	
	//썸네일 탭 액션
	@objc func handleThumbnail1Tap() {
		delegate?.didTapYoutubeThumbnail(at: 0)
	}
	
	@objc func handleThumbnail2Tap() {
		delegate?.didTapYoutubeThumbnail(at: 1)
	}
	
	func configure(with youtubeVideos: [YoutubeVideo]) {
		if let video1 = youtubeVideos.first {
			self.firstThumbnail.kf.setImage(with: video1.thumbnailURL)
			self.firstThumbnailTitle.text = video1.title
			self.firstThumbnail.tag = 0
		}
		
		if youtubeVideos.count > 1 {
			let video2 = youtubeVideos[1]
			self.secondThumbnail.kf.setImage(with: video2.thumbnailURL)
			self.secondThumbnailTitle.text = video2.title
			self.secondThumbnail.tag = 1
		}
	}
}
