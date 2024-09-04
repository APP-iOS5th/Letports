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
    
    var team: SportsTeam?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // 팀 로고
    private lazy var teamLogo: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    // 팀 이름
    private lazy var teamName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // URL 스택뷰
    private lazy var urlSV: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        return sv
    }()
    
    // 홈 아이콘, 이름 스택뷰
    lazy var homeURLSV = createSV(axis: .horizontal, alignment: .center, distribution: .fillProportionally)
    
    lazy var homeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "house.fill"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .lp_black
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 25),
            iv.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return iv
    }()
    
    lazy var homeLabel = createLabel(text: "홈페이지", fontSize: 14)
    
    // 인스타 아이콘, 이름 스택뷰
    lazy var instagramURLSV = createSV(axis: .horizontal,
                                       alignment: .center,
                                       distribution: .fillProportionally
                                       )
    
    lazy var instagramIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "InstagramColor"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 25),
            iv.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return iv
    }()
    
    lazy var instagramLabel = createLabel(text: "인스타그램", fontSize: 14)
    
    // 유튜뷰 아이콘, 이름 스택뷰
    lazy var youtubeURLSV = createSV(axis: .horizontal, alignment: .center, distribution: .fillProportionally)
    
    lazy var youtubeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "YoutubeIconFull"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 25),
            iv.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return iv
    }()
    
    lazy var youtubeLabel = createLabel(text: "유튜브", fontSize: 14)
    
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
        
        [homeIcon, homeLabel].forEach {
            homeURLSV.addArrangedSubview($0)
        }
        
        [instagramIcon, instagramLabel].forEach {
            instagramURLSV.addArrangedSubview($0)
        }
        
        [youtubeIcon, youtubeLabel].forEach {
            youtubeURLSV.addArrangedSubview($0)
        }
        
        [homeURLSV, instagramURLSV, youtubeURLSV]
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
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            teamLogo.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            teamLogo.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamLogo.heightAnchor.constraint(equalToConstant: 70),
            teamLogo.widthAnchor.constraint(equalToConstant: 70),
            
            teamName.leadingAnchor.constraint(equalTo: teamLogo.trailingAnchor, constant: 20),
            teamName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            teamName.heightAnchor.constraint(equalToConstant: 40),
            
            urlSV.topAnchor.constraint(equalTo: teamName.bottomAnchor, constant: 8),
            urlSV.leadingAnchor.constraint(equalTo: teamLogo.trailingAnchor, constant: 20),
            urlSV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            urlSV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            urlSV.heightAnchor.constraint(equalToConstant: 30),
            
            homeURLSV.topAnchor.constraint(equalTo: urlSV.topAnchor),
            homeURLSV.leadingAnchor.constraint(equalTo: urlSV.leadingAnchor),
            homeURLSV.trailingAnchor.constraint(equalTo: instagramURLSV.leadingAnchor, constant: -2),
            homeURLSV.bottomAnchor.constraint(equalTo: urlSV.bottomAnchor),
            
            instagramURLSV.topAnchor.constraint(equalTo: urlSV.topAnchor),
            instagramURLSV.leadingAnchor.constraint(equalTo: homeURLSV.trailingAnchor),
            instagramURLSV.trailingAnchor.constraint(equalTo: youtubeURLSV.leadingAnchor, constant: -6),
            instagramURLSV.bottomAnchor.constraint(equalTo: urlSV.bottomAnchor),
            
            youtubeURLSV.topAnchor.constraint(equalTo: urlSV.topAnchor),
            youtubeURLSV.leadingAnchor.constraint(equalTo: instagramURLSV.trailingAnchor),
            youtubeURLSV.bottomAnchor.constraint(equalTo: urlSV.bottomAnchor),
            youtubeURLSV.trailingAnchor.constraint(equalTo: urlSV.trailingAnchor),
            
            homeIcon.topAnchor.constraint(equalTo: homeURLSV.topAnchor),
            homeIcon.leadingAnchor.constraint(equalTo: homeURLSV.leadingAnchor),
            homeIcon.trailingAnchor.constraint(equalTo: homeLabel.leadingAnchor, constant: -6),
            homeIcon.bottomAnchor.constraint(equalTo: homeURLSV.bottomAnchor),
            
            homeLabel.topAnchor.constraint(equalTo: homeURLSV.topAnchor),
            homeLabel.leadingAnchor.constraint(equalTo: homeIcon.trailingAnchor),
            homeLabel.bottomAnchor.constraint(equalTo: homeURLSV.bottomAnchor),
            
            instagramIcon.topAnchor.constraint(equalTo: instagramURLSV.topAnchor),
            instagramIcon.leadingAnchor.constraint(equalTo: instagramURLSV.leadingAnchor),
            instagramIcon.trailingAnchor.constraint(equalTo: instagramLabel.leadingAnchor, constant: -6),
            instagramIcon.bottomAnchor.constraint(equalTo: instagramURLSV.bottomAnchor),
            
            instagramLabel.topAnchor.constraint(equalTo: instagramURLSV.topAnchor),
            instagramLabel.leadingAnchor.constraint(equalTo: instagramIcon.trailingAnchor),
            instagramLabel.bottomAnchor.constraint(equalTo: instagramURLSV.bottomAnchor),
            
            youtubeIcon.topAnchor.constraint(equalTo: youtubeURLSV.topAnchor),
            youtubeIcon.leadingAnchor.constraint(equalTo: youtubeURLSV.leadingAnchor),
            youtubeIcon.trailingAnchor.constraint(equalTo: youtubeLabel.leadingAnchor, constant: -6),
            youtubeIcon.bottomAnchor.constraint(equalTo: youtubeURLSV.bottomAnchor),
            
            youtubeLabel.topAnchor.constraint(equalTo: youtubeURLSV.topAnchor),
            youtubeLabel.leadingAnchor.constraint(equalTo: youtubeIcon.trailingAnchor),
            youtubeLabel.bottomAnchor.constraint(equalTo: youtubeURLSV.bottomAnchor),
            youtubeLabel.trailingAnchor.constraint(equalTo: youtubeURLSV.trailingAnchor),
        ])
        
        lazy var homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHomeTap))
        homeURLSV.addGestureRecognizer(homeTapGesture)
        homeURLSV.isUserInteractionEnabled = true
        
        lazy var instaTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInstaTap))
        instagramURLSV.addGestureRecognizer(instaTapGesture)
        instagramURLSV.isUserInteractionEnabled = true
        
        lazy var youtubeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleYoutubeTap))
        youtubeURLSV.addGestureRecognizer(youtubeTapGesture)
        youtubeURLSV.isUserInteractionEnabled = true
    }
    
    func configure(with team: SportsTeam) {
        self.team = team
        teamName.text = team.teamName
        
        guard let url = URL(string: team.teamLogo) else {
            teamLogo.image = UIImage(systemName: "person.circle")
            return
        }
        teamLogo.kf.setImage(with: url)
    }
    
    // 스택뷰 만들기
    func createSV(axis: NSLayoutConstraint.Axis,
                  alignment: UIStackView.Alignment,
                  distribution: UIStackView.Distribution
    ) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // 이미지 뷰 만들기
    func createImageView(systemName: String,
                         tintColor: UIColor? = nil,
                         contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        if let tintColor = tintColor {
            imageView.tintColor = tintColor
        }
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    // 라벨 만들기
    func createLabel(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    //MARK: -Objc Methods
    //url 탭 액션
    @objc func handleHomeTap() {
        if let team = self.team, let url = URL(string: team.homepage) {
            delegate?.didTapSNSButton(url: url)
        }
    }
    
    @objc func handleInstaTap() {
        if let team = self.team, let url = URL(string: team.instagram) {
            delegate?.didTapSNSButton(url: url)
        }
    }
    
    @objc func handleYoutubeTap() {
        if let team = self.team, let url = URL(string: team.youtube) {
            delegate?.didTapSNSButton(url: url)
        }
    }
}
