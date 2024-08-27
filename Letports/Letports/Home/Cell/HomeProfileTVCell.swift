//
//  ProfileTVCell.swift
//  Letports
//
//  Created by 홍준범 on 8/27/24.
//

import Foundation
import UIKit

protocol HomeProfileTVCellDelegate: AnyObject {
    func didTapSNSButton(url: URL)
}

class HomeProfileTVCell: UITableViewCell {
    
    weak var delegate: HomeProfileTVCellDelegate?
    
    var team: Team?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var teamLogo: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    private lazy var teamName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var urlSV: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        return sv
    }()
    
    private lazy var homepageIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Home"))
        
        return iv
    }()
    
    private lazy var homepageButton: UIButton = {
        let button = UIButton(type: .system) // 시스템 스타일 버튼 생성
        button.setTitle("홈페이지", for: .normal) // 버튼의 텍스트 설정
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12) // 텍스트의 폰트 설정
        button.addTarget(self, action: #selector(homepageButtonTapped), for: .touchUpInside) // 버튼 클릭 시 액션 연결
        return button
    }()
    
    private lazy var instagramIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Instagram"))
        
        return iv
    }()
    
    private lazy var instagramButton: UIButton = {
        let button = UIButton(type: .system) // 시스템 스타일 버튼 생성
        button.setTitle("공식 인스타", for: .normal) // 버튼의 텍스트 설정
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12) // 텍스트의 폰트 설정
        button.addTarget(self, action: #selector(instagramButtonTapped), for: .touchUpInside) // 버튼 클릭 시 액션 연결
        return button
    }()
    
    private lazy var youtubeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Youtube"))
        
        return iv
    }()
    
    private lazy var youtubeButton: UIButton = {
        let button = UIButton(type: .system) // 시스템 스타일 버튼 생성
        button.setTitle("공식 유튜브", for: .normal) // 버튼의 텍스트 설정
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12) // 텍스트의 폰트 설정
        button.addTarget(self, action: #selector(youtubeButtonTapped), for: .touchUpInside) // 버튼 클릭 시 액션 연결
        return button
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
        contentView.addSubview(containerView)
        contentView.backgroundColor = .lp_background_white
        
        [homepageIcon, homepageButton, instagramIcon, instagramButton, youtubeIcon, youtubeButton]
            .forEach {
                urlSV.addArrangedSubview($0)
            }
        
        [teamLogo, teamName, urlSV].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.widthAnchor.constraint(equalToConstant: 361),
            containerView.heightAnchor.constraint(equalToConstant: 110),
            
            teamLogo.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            teamLogo.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamLogo.heightAnchor.constraint(equalToConstant: 70),
            teamLogo.widthAnchor.constraint(equalToConstant: 70),
            
            teamName.leadingAnchor.constraint(equalTo: teamLogo.trailingAnchor, constant: 16),
            teamName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            
            urlSV.topAnchor.constraint(equalTo: teamName.bottomAnchor, constant: 8),
            urlSV.leadingAnchor.constraint(equalTo: teamLogo.trailingAnchor, constant: 16),
            urlSV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            urlSV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
    }
    
    //MARK: -Objc Methods
    //url 탭 액션
    @objc func homepageButtonTapped() {
        if let team = self.team, let url = URL(string: team.homepage) {
            delegate?.didTapSNSButton(url: url)
        }
    }
    
    @objc func instagramButtonTapped() {
        if let team = self.team, let url = URL(string: team.instagram) {
            delegate?.didTapSNSButton(url: url)
        }
    }
    
    @objc func youtubeButtonTapped() {
        if let team = self.team, let url = URL(string: team.youtube) {
            delegate?.didTapSNSButton(url: url)
        }
    }
    
    func configure(with team: Team) {
        teamName.text = team.teamName
        
        guard let url = URL(string: team.teamLogo) else {
            teamLogo.image = UIImage(systemName: "person.circle")
            return
        }
        teamLogo.kf.setImage(with: url)
    }
}
