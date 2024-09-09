//
//  GatheringTV.swift
//  Letports
//
//  Created by mosi on 9/6/24.
//

import UIKit
import Kingfisher

class GatheringTV: UITableViewCell {
    
    private lazy var colorCache: NSCache<NSString, UIColor> = {
        let cache = NSCache<NSString, UIColor>()
        return cache
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sportsTeamLabel: UILabel = {
        let label = UILabel()
        label.font = .lp_Font(.regular, size: 10)
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sportsLabel: UILabel = {
        let label = UILabel()
        label.font = .lp_Font(.regular, size: 10)
        label.textColor = .lp_black
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gatheringIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lp_gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var isGatheringMasterIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.image = UIImage(systemName: "crown.fill")
        iv.tintColor = .lp_main
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var gatheringName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gatheringInfo: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "lp_gray")
        label.textAlignment = .left
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gatheringMasterIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 5
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lp_gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var gatheringMasterName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var personIV: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.2.fill")
        iv.tintColor = UIColor(named: "lp_black")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var memberCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarIV: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar.circle.fill")
        iv.tintColor = UIColor(named: "lp_black")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var createGatheringDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.transform = CGAffineTransform.identity
        gatheringIV.image = nil
        gatheringMasterIV.image = nil
    }
    
    private var gatheringNameTrailingConstraintToMasterIV: NSLayoutConstraint?
    private var gatheringNameTrailingConstraintToContainer: NSLayoutConstraint?
    
    private func setupUI() {
        contentView.addSubview(containerView)
        contentView.backgroundColor = .lp_background_white
        
        [gatheringIV, gatheringName, gatheringInfo, gatheringMasterIV, gatheringMasterName, personIV, memberCount, calendarIV, createGatheringDate, isGatheringMasterIV, sportsTeamLabel, sportsLabel].forEach {
            containerView.addSubview($0)
        }
        
        gatheringNameTrailingConstraintToMasterIV = gatheringName.trailingAnchor.constraint(equalTo: isGatheringMasterIV.leadingAnchor, constant: 5)
        gatheringNameTrailingConstraintToContainer = gatheringName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            isGatheringMasterIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            isGatheringMasterIV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            isGatheringMasterIV.heightAnchor.constraint(equalToConstant: 15),
            isGatheringMasterIV.widthAnchor.constraint(equalToConstant: 15),
            
            gatheringIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            gatheringIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            gatheringIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            gatheringIV.widthAnchor.constraint(equalToConstant: 100),
            
            sportsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            sportsLabel.widthAnchor.constraint(equalToConstant: 30),
            sportsLabel.heightAnchor.constraint(equalToConstant: 20),
            sportsLabel.leadingAnchor.constraint(equalTo: gatheringIV.trailingAnchor, constant: 8),
            
            sportsTeamLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            sportsTeamLabel.widthAnchor.constraint(equalToConstant: 30),
            sportsTeamLabel.heightAnchor.constraint(equalToConstant: 20),
            sportsTeamLabel.leadingAnchor.constraint(equalTo: sportsLabel.trailingAnchor, constant: 5),
            
            gatheringName.leadingAnchor.constraint(equalTo: sportsTeamLabel.trailingAnchor, constant: 5),
            gatheringName.heightAnchor.constraint(equalToConstant: 20),
            gatheringName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            
            gatheringInfo.leadingAnchor.constraint(equalTo: gatheringIV.trailingAnchor, constant: 8),
            gatheringInfo.topAnchor.constraint(equalTo: gatheringName.bottomAnchor, constant: 4),
            gatheringInfo.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            gatheringMasterIV.leadingAnchor.constraint(equalTo: gatheringIV.trailingAnchor, constant: 10),
            gatheringMasterIV.widthAnchor.constraint(equalToConstant: 15),
            gatheringMasterIV.heightAnchor.constraint(equalToConstant: 15),
            gatheringMasterIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            gatheringMasterName.leadingAnchor.constraint(equalTo: gatheringMasterIV.trailingAnchor, constant: 4),
            gatheringMasterName.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            gatheringMasterName.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            personIV.leadingAnchor.constraint(equalTo: gatheringMasterName.trailingAnchor, constant: 8),
            personIV.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            personIV.widthAnchor.constraint(equalToConstant: 15),
            personIV.heightAnchor.constraint(equalToConstant: 15),
            personIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            memberCount.leadingAnchor.constraint(equalTo: personIV.trailingAnchor, constant: 4),
            memberCount.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            memberCount.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            calendarIV.leadingAnchor.constraint(equalTo: memberCount.trailingAnchor, constant: 8),
            calendarIV.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            calendarIV.widthAnchor.constraint(equalToConstant: 15),
            calendarIV.heightAnchor.constraint(equalToConstant: 15),
            calendarIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            createGatheringDate.leadingAnchor.constraint(equalTo: calendarIV.trailingAnchor, constant: 4),
            createGatheringDate.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            createGatheringDate.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    private func updateGatheringNameTrailingConstraint() {
        gatheringNameTrailingConstraintToMasterIV?.isActive = false
        gatheringNameTrailingConstraintToContainer?.isActive = false
        
        if isGatheringMasterIV.isHidden {
            gatheringNameTrailingConstraintToContainer?.isActive = true
        } else {
            gatheringNameTrailingConstraintToMasterIV?.isActive = true
        }
    }
    
    func configure(with gathering: Gathering, with sports: SportsTeam, with master: LetportsUser) {
        
        let date = gathering.gatheringCreateDate.dateValue()
        let dateString = date.toString(format: "yyyy-MM-dd")
        
        sportsLabel.text = sports.sportsName
        sportsLabel.textColor = .lp_black
        sportsLabel.backgroundColor = .lp_black.withAlphaComponent(0.1)
        sportsTeamLabel.text = sports.shortName
        sportsTeamLabel.backgroundColor = UIColor(hex: sports.logoHex).withAlphaComponent(0.1)
        sportsTeamLabel.textColor = UIColor(hex: sports.logoHex)
        isGatheringMasterIV.isHidden = true
        gatheringName.text = truncateText(gathering.gatherName, limit: 16)
        gatheringInfo.text = gathering.gatherInfo
        gatheringMasterName.text = truncateText(master.nickname, limit: 10)
        memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
        createGatheringDate.text = dateString
        
        if let gatheringUrl = URL(string: gathering.gatherImage) {
            gatheringIV.kf.setImage(with: gatheringUrl)
        } else {
            gatheringIV.image = nil
        }
        
        if let masterUrl = URL(string: master.image) {
            gatheringMasterIV.kf.setImage(with: masterUrl)
        } else {
            gatheringMasterIV.image = nil
        }
    }
    
    
    func configure(with gathering: Gathering, with sports: SportsTeam, with user: LetportsUser, with master: LetportsUser) {
        updateGatheringNameTrailingConstraint()
        let date = gathering.gatheringCreateDate.dateValue()
        let dateString = date.toString(format: "yyyy-MM-dd")
        
        sportsLabel.text = sports.sportsName
        sportsLabel.textColor = .lp_black
        sportsLabel.backgroundColor = .lp_black.withAlphaComponent(0.1)
        sportsTeamLabel.text = sports.shortName
        sportsTeamLabel.backgroundColor = UIColor(hex: sports.logoHex).withAlphaComponent(0.1)
        sportsTeamLabel.textColor = UIColor(hex: sports.logoHex)
        isGatheringMasterIV.isHidden = gathering.gatheringMaster != user.uid
        gatheringName.text = gathering.gatherName
        gatheringInfo.text = gathering.gatherInfo
        gatheringMasterName.text = truncateText(master.nickname, limit: 10)
        memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
        createGatheringDate.text = dateString
        
        if let gatheringUrl = URL(string: gathering.gatherImage) {
            gatheringIV.kf.setImage(with: gatheringUrl)
        } else {
            gatheringIV.image = nil
        }
        
        if let masterUrl = URL(string: master.image) {
            gatheringMasterIV.kf.setImage(with: masterUrl)
        } else {
            gatheringMasterIV.image = nil
        }
    }
    
}

private func truncateText(_ text: String, limit: Int) -> String {
    return text.count > limit ? String(text.prefix(limit)) + "..." : text
}
