//
//  GatheringImageTViCell.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import UIKit

protocol GatheringTitleTVCellDelegate: AnyObject {
	func didTapEditButton()
}


final class GatheringTitleTVCell: UITableViewCell {
	weak var delegate: GatheringTitleTVCellDelegate?
	
	private let titleLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 26, weight: .semibold)
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let masterNameLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 15, weight: .medium)
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let memberLabel: UILabel = {
		let lb = UILabel()
		lb.translatesAutoresizingMaskIntoConstraints = false
		lb.font = .systemFont(ofSize: 15, weight: .medium)
		lb.text = "현재인원 :"
		return lb
	}()
	
	private let spliteLabel: UILabel = {
		let lb = UILabel()
		lb.translatesAutoresizingMaskIntoConstraints = false
		lb.font = .systemFont(ofSize: 15, weight: .medium)
		lb.text = "/"
		return lb
	}()
	
	private let gatherMaxMemberLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 15, weight: .bold)
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let gatherNowMemberLabel: UILabel = {
		let lb = UILabel()
		lb.font = .systemFont(ofSize: 15, weight: .bold)
		lb.translatesAutoresizingMaskIntoConstraints = false
		return lb
	}()
	
	private let memberSV: UIStackView = {
		let sv = UIStackView()
		sv.translatesAutoresizingMaskIntoConstraints = false
		sv.axis = .horizontal
		sv.spacing = 1
		return sv
	}()
	
	private let titleSV: UIStackView = {
		let sv = UIStackView()
		sv.translatesAutoresizingMaskIntoConstraints = false
		sv.alignment = .leading
		sv.axis = .vertical
		sv.spacing = 5
		return sv
	}()
	
	private let editBtn: UIButton = {
		let btn = UIButton()
		var config = UIButton.Configuration.plain()
		config.image = UIImage(systemName: "pencil.circle")
		config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
		btn.configuration = config
		btn.translatesAutoresizingMaskIntoConstraints = false
		return btn
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	private func setupUI() {
		self.contentView.backgroundColor = .lp_background_white
		
		[editBtn, titleSV].forEach {
			self.contentView.addSubview($0)
		}
		
		[titleLabel, masterNameLabel, memberSV].forEach {
			self.titleSV.addArrangedSubview($0)
		}
		
		[memberLabel, gatherNowMemberLabel, spliteLabel, gatherMaxMemberLabel].forEach {
			self.memberSV.addArrangedSubview($0)
		}
		
		NSLayoutConstraint.activate([
			titleSV.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
			titleSV.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			titleSV.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -7),
			
			editBtn.topAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 5),
			editBtn.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			editBtn.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
			editBtn.widthAnchor.constraint(equalToConstant: 36),
			editBtn.heightAnchor.constraint(equalToConstant: 36)
		])
		
		editBtn.addTarget(self, action: #selector(editBtnTap), for: .touchUpInside)
	}
	
	func configureCell(data: SampleGathering2, currentUser: LetportsUser, masterNickname: String) {
		titleLabel.text = data.gatherName
		masterNameLabel.text = "모임장: \(masterNickname)"
		gatherNowMemberLabel.text = "\(data.gatherNowMember)"
		gatherMaxMemberLabel.text = "\(data.gatherMaxMember)"
		let isMaster = currentUser.uid == data.gatheringMaster
		editBtn.isHidden = !isMaster
	}
	
	@objc func editBtnTap() {
		print("모임장편집버튼")
		delegate?.didTapEditButton()
	}
}
