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
    
    // 팀 로고
    private lazy var teamLogo: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
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
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        return sv
    }()
    
    // 홈 아이콘, 이름 스택뷰
    lazy var homeURLSV = createSV(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    let homeIcon = UIImageView(image: UIImage(named: "Home"))
    lazy var homeLabel = createLabel(text: "홈페이지", fontSize: 12)
    
    // 인스타 아이콘, 이름 스택뷰
    lazy var instagramURLSV = createSV(axis: .horizontal,
                                       alignment: .fill,
                                       distribution: .fillProportionally,
                                       spacing: 4)
    
    let instagramIcon = UIImageView(image: UIImage(named: "Instagram"))
    lazy var instagramLabel = createLabel(text: "공식 인스타", fontSize: 12)
    
    // 유튜뷰 아이콘, 이름 스택뷰
    lazy var youtubeURLSV = createSV(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    let youtubeIcon = UIImageView(image: UIImage(named: "Youtube"))
    lazy var youtubeLabel = createLabel(text: "공식 유튜브", fontSize: 12)
    
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
            
            teamName.leadingAnchor.constraint(equalTo: teamLogo.trailingAnchor, constant: 16),
            teamName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            teamName.heightAnchor.constraint(equalToConstant: 40),
            
            urlSV.topAnchor.constraint(equalTo: teamName.bottomAnchor, constant: 8),
            urlSV.leadingAnchor.constraint(equalTo: teamLogo.trailingAnchor, constant: 16),
            urlSV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            urlSV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            urlSV.heightAnchor.constraint(equalToConstant: 30)
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
    
    func configure(with team: Team) {
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
                  distribution: UIStackView.Distribution,
                  spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
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
