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
        whiteBox.layer.cornerRadius = 15
        whiteBox.layer.shadowColor = UIColor.black.cgColor
        whiteBox.layer.shadowOpacity = 0.1
        whiteBox.layer.shadowOffset = CGSize(width: 0, height: 2)
        whiteBox.layer.shadowRadius = 5
        whiteBox.translatesAutoresizingMaskIntoConstraints = false
        
        return whiteBox
    }()
    
    lazy var teamProfile: UIStackView = {
        let profile = createStackView(axis: .horizontal, alignment: .center, distribution: .fillEqually, spacing: 8)
        
        let teamIcon = createImageView(systemName: "circle.fill")
        teamIcon.widthAnchor.constraint(equalToConstant: 70).isActive = true
        teamIcon.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let profileLabel = createStackView(axis: .vertical, alignment: .fill, distribution: .fillProportionally, spacing: 20)
        
        let teamLabel = createLabel(text: "FC 서울", fontSize: 30, fontWeight: .bold)
        
        let urlLabel = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        
        //홈페이지
        let url1StackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        let homeIcon = createImageView(systemName: "house.fill", tintColor: .lp_black)
        let url1 = createLabel(text: "홈페이지", fontSize: 12)
        url1StackView.addArrangedSubview(homeIcon)
        url1StackView.addArrangedSubview(url1)
        
        //공식 인스타
        let url2StackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        let instaIcon = createImageView(systemName: "rectangle.fill")
        let url2 = createLabel(text: "공식 인스타", fontSize: 12)
        url2StackView.addArrangedSubview(instaIcon)
        url2StackView.addArrangedSubview(url2)
        
        //공식 유튜브
        let url3StackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        let youtubeIcon = createImageView(systemName: "video.fill")
        let url3 = createLabel(text: "공식 유튜브", fontSize: 12)
        url3StackView.addArrangedSubview(youtubeIcon)
        url3StackView.addArrangedSubview(url3)
        
       
        urlLabel.addArrangedSubview(url1StackView)
        urlLabel.addArrangedSubview(url2StackView)
        urlLabel.addArrangedSubview(url3StackView)
        
        profileLabel.addArrangedSubview(teamLabel)
        profileLabel.addArrangedSubview(urlLabel)
        
        profile.addArrangedSubview(teamIcon)
        profile.addArrangedSubview(profileLabel)
        
        return profile
    }()
    
    let secondLabel: UILabel = {
        let label = UILabel()
        label.text = "FC 서울의 최신 영상"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .lpBlack
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let secondContainerView: UIView = {
        let whiteBox = UIView()
        whiteBox.backgroundColor = .white
        whiteBox.layer.cornerRadius = 15
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
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .lpBlack
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let gatheringScrollView: UIScrollView = {
        let gatheringScroll = UIScrollView()
        gatheringScroll.translatesAutoresizingMaskIntoConstraints = false
        gatheringScroll.showsHorizontalScrollIndicator = false
        
        return gatheringScroll
    }()
    
    lazy var gatheringStackView: UIStackView = {
        let gatheringView = createStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 2)
        
        let image1 = UIImageView()
        image1.contentMode = .scaleAspectFit
        image1.image = UIImage(systemName: "house.fill")
        image1.translatesAutoresizingMaskIntoConstraints = false
        
        let image2 = UIImageView()
        image2.contentMode = .scaleAspectFit
        image2.image = UIImage(systemName: "house.fill")
        image2.translatesAutoresizingMaskIntoConstraints = false
        
        let image3 = UIImageView()
        image3.contentMode = .scaleAspectFit
        image3.image = UIImage(systemName: "house.fill")
        image3.translatesAutoresizingMaskIntoConstraints = false
        
        let image4 = UIImageView()
        image4.contentMode = .scaleAspectFit
        image4.image = UIImage(systemName: "house.fill")
        image4.translatesAutoresizingMaskIntoConstraints = false
        
        gatheringView.addArrangedSubview(image1)
        gatheringView.addArrangedSubview(image2)
        gatheringView.addArrangedSubview(image3)
        gatheringView.addArrangedSubview(image4)
        
        return gatheringView
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
        view.addSubview(gatheringScrollView)
        gatheringScrollView.addSubview(gatheringStackView)
        
        
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
            
            gatheringScrollView.topAnchor.constraint(equalTo: thirdLabel.bottomAnchor, constant: 20),
            gatheringScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gatheringScrollView.widthAnchor.constraint(equalToConstant: 300),
            gatheringScrollView.heightAnchor.constraint(equalToConstant: 200),
            
            gatheringStackView.topAnchor.constraint(equalTo: gatheringScrollView.topAnchor),
            gatheringStackView.leadingAnchor.constraint(equalTo: gatheringScrollView.leadingAnchor),
            gatheringStackView.trailingAnchor.constraint(equalTo: gatheringScrollView.trailingAnchor),
            gatheringStackView.bottomAnchor.constraint(equalTo: gatheringScrollView.bottomAnchor),
            gatheringStackView.heightAnchor.constraint(equalTo: gatheringScrollView.heightAnchor)
        ])
    }
    
    func createStackView(axis: NSLayoutConstraint.Axis,
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
    
    func createLabel(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
