//
//  HomeVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit

class HomeVC: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    let viewModel = HomeViewModel()
    
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
        let profile = createStackView(axis: .horizontal, alignment: .center, distribution: .fillProportionally, spacing: 8)
        
        let teamIcon = UIImageView(image: UIImage(named: "FCSeoul"))
        teamIcon.widthAnchor.constraint(equalToConstant: 70).isActive = true
        teamIcon.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let spacerView1 = UIView()
        spacerView1.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        let profileLabel = createStackView(axis: .vertical, alignment: .fill, distribution: .fillProportionally, spacing: 0)
        
        let teamLabel = createLabel(text: "FC 서울", fontSize: 30, fontWeight: .bold)
        
        let spacerView = UIView()
        spacerView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        let urlLabel = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        
        //홈페이지
        let url1StackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        let homeIcon = UIImageView(image: UIImage(named: "Home"))
        let url1 = createLabel(text: "홈페이지", fontSize: 12)
        url1StackView.addArrangedSubview(homeIcon)
        url1StackView.addArrangedSubview(url1)
        
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHomeTap))
        url1StackView.addGestureRecognizer(homeTapGesture)
        url1StackView.isUserInteractionEnabled = true
        
        //공식 인스타
        let url2StackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        let instaIcon = UIImageView(image: UIImage(named: "Instagram"))
        let url2 = createLabel(text: "공식 인스타", fontSize: 12)
        url2StackView.addArrangedSubview(instaIcon)
        url2StackView.addArrangedSubview(url2)
        
        let instaTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInstaTap))
        url2StackView.addGestureRecognizer(instaTapGesture)
        url2StackView.isUserInteractionEnabled = true
        
        //공식 유튜브
        let url3StackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
        let youtubeIcon = UIImageView(image: UIImage(named: "Youtube"))
        let url3 = createLabel(text: "공식 유튜브", fontSize: 12)
        url3StackView.addArrangedSubview(youtubeIcon)
        url3StackView.addArrangedSubview(url3)
        
        let youtubeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleYoutubeTap))
        url3StackView.addGestureRecognizer(youtubeTapGesture)
        url3StackView.isUserInteractionEnabled = true
        
        
        urlLabel.addArrangedSubview(url1StackView)
        urlLabel.addArrangedSubview(url2StackView)
        urlLabel.addArrangedSubview(url3StackView)
        
        profileLabel.addArrangedSubview(teamLabel)
        profileLabel.addArrangedSubview(spacerView)
        profileLabel.addArrangedSubview(urlLabel)
        
        profile.addArrangedSubview(teamIcon)
        profile.addArrangedSubview(spacerView1)
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
    
    lazy var thumbnailStackView: UIStackView = {
        let stackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 20)
        
        //첫번째 썸네일
        let firstThumbnailStackView = createStackView(axis: .vertical, alignment: .fill, distribution: .fillEqually, spacing: 5)
        
        let thumbnail1 = UIImageView()
        thumbnail1.contentMode = .scaleAspectFill
        thumbnail1.layer.cornerRadius = 10
        thumbnail1.clipsToBounds = true
        thumbnail1.translatesAutoresizingMaskIntoConstraints = false
        
        let thumbnailTitle1 = UILabel()
        thumbnailTitle1.text = "줌 인 서울 I 서울의 상승세 어떻게 막을래? I 서울 1-0 인천 I K리그1 2024 R25"
        thumbnailTitle1.font = UIFont.systemFont(ofSize: 10)
        thumbnailTitle1.numberOfLines = 2
        thumbnailTitle1.lineBreakMode = .byTruncatingTail
        thumbnailTitle1.translatesAutoresizingMaskIntoConstraints = false
        
        firstThumbnailStackView.addArrangedSubview(thumbnail1)
        firstThumbnailStackView.addArrangedSubview(thumbnailTitle1)
        
        thumbnail1.heightAnchor.constraint(equalTo: firstThumbnailStackView.heightAnchor, multiplier: 0.75).isActive = true
        thumbnailTitle1.heightAnchor.constraint(equalTo: firstThumbnailStackView.heightAnchor, multiplier: 0.25).isActive = true
        
        //첫번째 썸네일
        let thumbnail1TapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail1Tap))
        firstThumbnailStackView.addGestureRecognizer(thumbnail1TapGesture)
        firstThumbnailStackView.isUserInteractionEnabled = true
        
        //두번째 썸네일
        let secondThumbnailStackView = createStackView(axis: .vertical, alignment: .fill, distribution: .fillEqually, spacing: 5)
        
        let thumbnail2 = UIImageView()
        thumbnail2.contentMode = .scaleAspectFill
        thumbnail2.layer.cornerRadius = 10
        thumbnail2.clipsToBounds = true
        thumbnail2.translatesAutoresizingMaskIntoConstraints = false
        
        let thumbnailTitle2 = UILabel()
        thumbnailTitle2.text = "줌 인 서울 I 서울의 상승세 어떻게 막을래? I 서울 1-0 인천 I K리그1 2024 R25"
        thumbnailTitle2.font = UIFont.systemFont(ofSize: 10)
        thumbnailTitle2.numberOfLines = 2
        thumbnailTitle2.lineBreakMode = .byTruncatingTail
        thumbnailTitle2.translatesAutoresizingMaskIntoConstraints = false
        
        secondThumbnailStackView.addArrangedSubview(thumbnail2)
        secondThumbnailStackView.addArrangedSubview(thumbnailTitle2)
        
        //두번째 썸네일
        let thumbnail2TapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail2Tap))
        secondThumbnailStackView.addGestureRecognizer(thumbnail2TapGesture)
        secondThumbnailStackView.isUserInteractionEnabled = true
        
        thumbnail2.heightAnchor.constraint(equalTo: secondThumbnailStackView.heightAnchor, multiplier: 0.75).isActive = true
        thumbnailTitle2.heightAnchor.constraint(equalTo: secondThumbnailStackView.heightAnchor, multiplier: 0.25).isActive = true
        
        stackView.addArrangedSubview(firstThumbnailStackView)
        stackView.addArrangedSubview(secondThumbnailStackView)
        
        
        let videoID1 = "aWp0mk2PEyI"
        let videoID2 = "aWp0mk2PEyI"
        loadThumbnail(for: videoID1, into: thumbnail1)
        loadThumbnail(for: videoID2, into: thumbnail2)
        
        return stackView
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
        image1.image = UIImage(systemName: "circle")
        image1.tintColor = .lpMain
        image1.translatesAutoresizingMaskIntoConstraints = false
        image1.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image1.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let image2 = UIImageView()
        image2.contentMode = .scaleAspectFit
        image2.image = UIImage(systemName: "star")
        image2.tintColor = .lpMain
        image2.translatesAutoresizingMaskIntoConstraints = false
        image2.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image2.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let image3 = UIImageView()
        image3.contentMode = .scaleAspectFit
        image3.image = UIImage(systemName: "rectangle")
        image3.tintColor = .lpMain
        image3.translatesAutoresizingMaskIntoConstraints = false
        image3.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image3.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let image4 = UIImageView()
        image4.contentMode = .scaleAspectFit
        image4.image = UIImage(systemName: "house.fill")
        image4.tintColor = .lpMain
        image4.translatesAutoresizingMaskIntoConstraints = false
        image4.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image4.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
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
        secondContainerView.addSubview(thumbnailStackView)
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
            
            thumbnailStackView.topAnchor.constraint(equalTo: secondContainerView.topAnchor, constant: 10),
            thumbnailStackView.leftAnchor.constraint(equalTo: secondContainerView.leftAnchor, constant: 30),
            thumbnailStackView.widthAnchor.constraint(equalToConstant: 300),
            thumbnailStackView.heightAnchor.constraint(equalToConstant: 100),
            
            thirdLabel.topAnchor.constraint(equalTo: secondContainerView.bottomAnchor, constant: 20),
            thirdLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            
            gatheringScrollView.topAnchor.constraint(equalTo: thirdLabel.bottomAnchor, constant: 20),
            gatheringScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            gatheringScrollView.widthAnchor.constraint(equalToConstant: 450),
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
    
    @objc func handleHomeTap() {
        if let url = URL(string: "http://www.fcseoul.com") {
            presentBottomSheet(with: url)
        }
        print("홈페이지")
    }
    
    @objc func handleInstaTap() {
        if let url = URL(string: "https://www.instagram.com/fcseoul") {
            presentBottomSheet(with: url)
        }
        print("인스타그램")
    }
    
    @objc func handleYoutubeTap() {
        if let url = URL(string: "https://www.youtube.com/@FCSEOUL") {
            presentBottomSheet(with: url)
        }
        print("유튜브")
    }
    
    func presentBottomSheet(with url: URL) {
        let bottomSheetVC = URLVC(url: url)
        bottomSheetVC.modalPresentationStyle = .pageSheet
        
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(bottomSheetVC, animated: true, completion: nil)
    }
    
    //MARK: 유튜브 썸네일
    func loadThumbnail(for videoID: String, into imageView: UIImageView) {
        let urlString = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Error loading image:", error ?? "Unknown error")
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
    
    @objc func handleThumbnail1Tap() {
        let videoID = "aWp0mk2PEyI"
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
            presentBottomSheet(with: url)
        }
    }
    
    @objc func handleThumbnail2Tap() {
        let videoID = "aWp0mk2PEyI"
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
            presentBottomSheet(with: url)
        }
    }
        
}
