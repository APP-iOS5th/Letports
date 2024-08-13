//
//  HomeVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class HomeVC: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Letports"
        title.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        title.textColor = .lpSub
        title.frame = CGRect(x: 0, y: 0, width: 140, height: 22)
        
        return title
    }()

    let teamChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("팀 변경", for: .normal)
        button.setTitleColor(.lpBlack, for: .normal)
        button.backgroundColor = .none
        button.layer.cornerRadius = 10
        
        button.frame = CGRect(x: 0, y: 0, width: 61, height: 22)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    let firstContainerView: UIView = {
        let whiteBox = UIView()
        whiteBox.backgroundColor = .white
        whiteBox.layer.cornerRadius = 10
        whiteBox.layer.shadowColor = UIColor.black.cgColor
        whiteBox.layer.shadowOpacity = 0.1
        whiteBox.layer.shadowOffset = CGSize(width: 0, height: 2)
        whiteBox.layer.shadowRadius = 5
        whiteBox.translatesAutoresizingMaskIntoConstraints = false
        
        return whiteBox
    }()
    
    lazy var teamProfile: UIStackView = {
        let profile = UIStackView()
        profile.axis = .horizontal
        profile.alignment = .leading
        profile.distribution = .equalSpacing
        profile.spacing = 8
        profile.translatesAutoresizingMaskIntoConstraints = false
        
        let teamIcon = UIImageView()
        teamIcon.image = UIImage(systemName: "circle.fill")
        teamIcon.contentMode = .scaleAspectFit
        teamIcon.frame.size = CGSize(width: 70, height: 70)
        teamIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let profileLabel = UIStackView()
        profileLabel.axis = .vertical
        profile.alignment = .fill
        profile.distribution = .fillProportionally
        profile.spacing = 4
        profile.translatesAutoresizingMaskIntoConstraints = false
        
        let teamLabel = UILabel()
        teamLabel.text = "FC 서울"
        teamLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let urlLabel = UIStackView()
        urlLabel.axis = .horizontal
        urlLabel.alignment = .fill
        urlLabel.distribution = .fillProportionally
        urlLabel.spacing = 4
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let url = UILabel()
        url.text = "홈페이지"
        url.font = UIFont.systemFont(ofSize: 12)
        url.translatesAutoresizingMaskIntoConstraints = false
        
        let url2 = UILabel()
        url2.text = "공식 인스타"
        url2.font = UIFont.systemFont(ofSize: 12)
        
        url2.translatesAutoresizingMaskIntoConstraints = false
        
        let url3 = UILabel()
        url3.text = "공식 유튜브"
        url3.font = UIFont.systemFont(ofSize: 12)
        url3.translatesAutoresizingMaskIntoConstraints = false
        
        
        urlLabel.addArrangedSubview(url)
        urlLabel.addArrangedSubview(url2)
        urlLabel.addArrangedSubview(url3)
        profileLabel.addArrangedSubview(teamLabel)
        profileLabel.addArrangedSubview(urlLabel)
        profile.addArrangedSubview(teamIcon)
        profile.addArrangedSubview(profileLabel)
        
        NSLayoutConstraint.activate([
            teamIcon.topAnchor.constraint(equalTo: profile.topAnchor, constant: 6),
            teamIcon.leftAnchor.constraint(equalTo: profile.leftAnchor, constant: 10),
        ])
        
        return profile
    }()
    
    let secondLabel: UILabel = {
        let label = UILabel()
        label.text = "FC서울의 최신 영상"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .lpBlack
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let secondContainerView: UIView = {
        let whiteBox = UIView()
        whiteBox.backgroundColor = .white
        whiteBox.layer.cornerRadius = 10
        whiteBox.layer.shadowColor = UIColor.black.cgColor
        whiteBox.layer.shadowOpacity = 0.1
        whiteBox.layer.shadowOffset = CGSize(width: 0, height: 2)
        whiteBox.layer.shadowRadius = 5
        whiteBox.translatesAutoresizingMaskIntoConstraints = false
        
        return whiteBox
    }()
    
    let thirdLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 소모임🔥"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .lpBlack
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let thirdContainerView: UIView = {
        let whiteBox = UIView()
        whiteBox.backgroundColor = .white
        whiteBox.layer.cornerRadius = 10
        whiteBox.layer.shadowColor = UIColor.black.cgColor
        whiteBox.layer.shadowOpacity = 0.1
        whiteBox.layer.shadowOffset = CGSize(width: 0, height: 2)
        whiteBox.layer.shadowRadius = 5
        whiteBox.translatesAutoresizingMaskIntoConstraints = false
        
        return whiteBox
    }()
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lpBackgroundWhite
      
        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: teamChangeButton)
        
        firstContainerView.addSubview(teamProfile)
        view.addSubview(firstContainerView)
        view.addSubview(secondLabel)
        view.addSubview(secondContainerView)
        view.addSubview(thirdLabel)
        view.addSubview(thirdContainerView)
        
        
        NSLayoutConstraint.activate([
            firstContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            firstContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstContainerView.widthAnchor.constraint(equalToConstant: 361),
            firstContainerView.heightAnchor.constraint(equalToConstant: 110),
            
            teamProfile.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 10),
            teamProfile.leftAnchor.constraint(equalTo: firstContainerView.leftAnchor, constant: 10),
            teamProfile.rightAnchor.constraint(equalTo: firstContainerView.rightAnchor, constant: -10),
            teamProfile.bottomAnchor.constraint(equalTo: firstContainerView.bottomAnchor, constant: -10),
            
            secondLabel.topAnchor.constraint(equalTo: firstContainerView.bottomAnchor, constant: 20),
            secondLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            
            secondContainerView.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 20),
            secondContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondContainerView.widthAnchor.constraint(equalToConstant: 361),
            secondContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            thirdLabel.topAnchor.constraint(equalTo: secondContainerView.bottomAnchor, constant: 20),
            thirdLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            
            thirdContainerView.topAnchor.constraint(equalTo: thirdLabel.bottomAnchor, constant: 20),
            thirdContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdContainerView.widthAnchor.constraint(equalToConstant: 300),
            thirdContainerView.heightAnchor.constraint(equalToConstant: 200)
            
        ])
    }
}
