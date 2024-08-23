//
//  HomeVC.swift
//  Letports
//
//  Created by John Yun on 8/8/24.
//

import UIKit
import Combine
import Kingfisher

class HomeVC: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
    
    lazy var firstContainerView = createWhiteBox()
    
    lazy var teamProfileStackView = createStackView(axis: .horizontal, alignment: .center, distribution: .fillProportionally, spacing: 16)
    
    lazy var teamLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 팀 이름 있는 세로 스택뷰
    lazy var teamProfileStackView2 = createStackView(axis: .vertical, alignment: .fill, distribution: .fillProportionally, spacing: 16)
    
    lazy var teamName = createLabel(text: "", fontSize: 30, fontWeight: .bold)
    
    // URL스택뷰
    lazy var urlStackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    
    // 홈 아이콘, 이름 스택뷰
    lazy var homeURLStackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    let homeIcon = UIImageView(image: UIImage(named: "Home"))
    lazy var homeLabel = createLabel(text: "홈페이지", fontSize: 12)
    
    // 인스타 아이콘, 이름 스택뷰
    lazy var instagramURLStackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    let instagramIcon = UIImageView(image: UIImage(named: "Instagram"))
    lazy var instagramLabel = createLabel(text: "공식 인스타", fontSize: 12)
    
    // 유튜뷰 아이콘, 이름 스택뷰
    lazy var youtubeURLStackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    let youtubeIcon = UIImageView(image: UIImage(named: "Youtube"))
    lazy var youtubeLabel = createLabel(text: "공식 유튜브", fontSize: 12)
    
    let secondLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .lpBlack
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //유튜브 썸네일 흰 배경
    lazy var secondContainerView = createWhiteBox()
    
    //썸네일 전체 스택뷰
    lazy var thumbnailStackView = createStackView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 20)
    
    //썸네일1 스택뷰
    lazy var firstThumbnailStackView = createStackView(axis: .vertical, alignment: .fill, distribution: .fillEqually, spacing: 5)
    
    //썸네일1 이미지
    lazy var thumbnail1: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    //썸네일1 제목
    lazy var thumbnailTitle1: UILabel = {
        let label = UILabel()
        label.text = "제목1"
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //썸네일2 스택뷰
    lazy var secondThumbnailStackView = createStackView(axis: .vertical, alignment: .fill, distribution: .fillEqually, spacing: 5)
    
    //썸네일2 이미지
    lazy var thumbnail2: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    //썸네일2 제목
    lazy var thumbnailTitle2: UILabel = {
        let label = UILabel()
        label.text = "제목2"
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //추천 소모임 뷰
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
        let gatheringView = createStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 6)
        
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
        
        gatheringView.addArrangedSubview(image1)
        gatheringView.addArrangedSubview(image2)
        
        return gatheringView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$team
            .sink { [weak self] team in
                guard let self = self, let team = team else { return }
                if let logoURL = team.teamLogo {
                    self.teamLogo.kf.setImage(with: logoURL)
                } else {
                    self.teamLogo.image = UIImage(named: "home")
                }
                self.teamName.text = team.teamName
                self.secondLabel.text = "\(team.teamName ?? "")의 최신 영상"
            }
            .store(in: &cancellables)
        
        viewModel.$latestYoutubeVideos
            .sink { [weak self] videos in
                guard let self = self else { return }
                
                if let video1 = videos.first {
                    self.thumbnail1.kf.setImage(with: video1.thumbnailURL)
                    self.thumbnailTitle1.text = video1.title
                    self.thumbnail1.tag = 0
                }
                
                if videos.count > 1 {
                    let video2 = videos[1]
                    self.thumbnail2.kf.setImage(with: video2.thumbnailURL)
                    self.thumbnailTitle2.text = video2.title
                    self.thumbnail2.tag = 1
                }
            }
            .store(in: &cancellables)
        
        viewModel.$gatherings
            .sink { [weak self] gatherings in
                guard let self = self else { return }
                self.updateGatheringImages(gatherings)
            }
            .store(in: &cancellables)
    }
    
    private func updateGatheringImages(_ gatherings: [Gathering]) {
        gatheringStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gatherings.forEach { gathering in
            if let url = gathering.gatheringImage {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.kf.setImage(with: url, completionHandler: { result in
                    switch result {
                    case .success(let value):
                        print("Image loaded successfully: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("Error loading image: \(error.localizedDescription)")
                    }
                })
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
                gatheringStackView.addArrangedSubview(imageView)
            }
        }
    }
    
    func setupUI() {
        view.backgroundColor = .lpBackgroundWhite
        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: teamChangeButton)
        
        profileLayout()
        view.addSubview(secondLabel)
        youtubeThumbnailLayout()
        secondContainerView.addSubview(thumbnailStackView)
        view.addSubview(secondContainerView)
        view.addSubview(thirdLabel)
        view.addSubview(gatheringScrollView)
        gatheringScrollView.addSubview(gatheringStackView)
        
        layoutVC()
    }
    
    // 제목, 팀변경 버튼
    func profileLayout() {
        homeURLStackView.addArrangedSubview(homeIcon)
        homeURLStackView.addArrangedSubview(homeLabel)
        instagramURLStackView.addArrangedSubview(instagramIcon)
        instagramURLStackView.addArrangedSubview(instagramLabel)
        youtubeURLStackView.addArrangedSubview(youtubeIcon)
        youtubeURLStackView.addArrangedSubview(youtubeLabel)
        urlStackView.addArrangedSubview(homeURLStackView)
        urlStackView.addArrangedSubview(instagramURLStackView)
        urlStackView.addArrangedSubview(youtubeURLStackView)
        
        teamProfileStackView2.addArrangedSubview(teamName)
        teamProfileStackView2.addArrangedSubview(urlStackView)
        
        teamProfileStackView.addArrangedSubview(teamLogo)
        teamProfileStackView.addArrangedSubview(teamProfileStackView2)
        
        firstContainerView.addSubview(teamProfileStackView)
        view.addSubview(firstContainerView)
        
        lazy var homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHomeTap))
        homeURLStackView.addGestureRecognizer(homeTapGesture)
        homeURLStackView.isUserInteractionEnabled = true
        
        lazy var instaTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInstaTap))
        instagramURLStackView.addGestureRecognizer(instaTapGesture)
        instagramURLStackView.isUserInteractionEnabled = true
        
        lazy var youtubeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleYoutubeTap))
        youtubeURLStackView.addGestureRecognizer(youtubeTapGesture)
        youtubeURLStackView.isUserInteractionEnabled = true
    }
    
    //썸네일 레이아웃
    func youtubeThumbnailLayout() {
        firstThumbnailStackView.addArrangedSubview(thumbnail1)
        firstThumbnailStackView.addArrangedSubview(thumbnailTitle1)
        secondThumbnailStackView.addArrangedSubview(thumbnail2)
        secondThumbnailStackView.addArrangedSubview(thumbnailTitle2)
        
        //첫번째 썸네일 탭 제스쳐
        let thumbnail1TapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail1Tap))
        firstThumbnailStackView.addGestureRecognizer(thumbnail1TapGesture)
        firstThumbnailStackView.isUserInteractionEnabled = true
        
        //두번째 썸네일
        let thumbnail2TapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail2Tap))
        secondThumbnailStackView.addGestureRecognizer(thumbnail2TapGesture)
        secondThumbnailStackView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            thumbnail1.heightAnchor.constraint(equalTo: firstThumbnailStackView.heightAnchor, multiplier: 0.75),
            thumbnailTitle1.heightAnchor.constraint(equalTo: firstThumbnailStackView.heightAnchor, multiplier: 0.25),
            thumbnail2.heightAnchor.constraint(equalTo: secondThumbnailStackView.heightAnchor, multiplier: 0.75),
            thumbnailTitle2.heightAnchor.constraint(equalTo: secondThumbnailStackView.heightAnchor, multiplier: 0.25)
        ])
        
        thumbnailStackView.addArrangedSubview(firstThumbnailStackView)
        thumbnailStackView.addArrangedSubview(secondThumbnailStackView)
    }
    
    // VC레이아웃
    func layoutVC() {
        NSLayoutConstraint.activate([
            firstContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            firstContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstContainerView.widthAnchor.constraint(equalToConstant: 361),
            firstContainerView.heightAnchor.constraint(equalToConstant: 110),
            
            teamProfileStackView.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 10),
            teamProfileStackView.leftAnchor.constraint(equalTo: firstContainerView.leftAnchor, constant: 10),
            teamProfileStackView.rightAnchor.constraint(equalTo: firstContainerView.rightAnchor, constant: -10),
            teamProfileStackView.bottomAnchor.constraint(equalTo: firstContainerView.bottomAnchor, constant: -10),
            
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
    
    // 배경 흰 네모
    func createWhiteBox(backgroundColor: UIColor = .white,
                        cornerRadius: CGFloat = 15,
                        shadowColor: UIColor = .black,
                        shadowOpacity: Float = 0.1,
                        shadowOffset: CGSize = CGSize(width: 0, height: 2),
                        shadowRadius: CGFloat = 5) -> UIView {
        let whiteBox = UIView()
        whiteBox.backgroundColor = backgroundColor
        whiteBox.layer.cornerRadius = cornerRadius
        whiteBox.layer.shadowColor = shadowColor.cgColor
        whiteBox.layer.shadowOpacity = shadowOpacity
        whiteBox.layer.shadowOffset = shadowOffset
        whiteBox.layer.shadowRadius = shadowRadius
        whiteBox.translatesAutoresizingMaskIntoConstraints = false
        
        return whiteBox
    }
    
    // 스택뷰 만들기
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
    
    @objc func handleHomeTap() {
        if let url = viewModel.team?.homepageURL {
            presentBottomSheet(with: url)
        }
        print("홈페이지")
    }
    
    @objc func handleInstaTap() {
        if let url = viewModel.team?.instagramURL {
            presentBottomSheet(with: url)
        }
        print("인스타그램")
    }
    
    @objc func handleYoutubeTap() {
        if let url = viewModel.team?.youtubeURL {
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
    
    @objc func handleThumbnail1Tap() {
        openYoutubeVideo(at: 0)
    }
    
    @objc func handleThumbnail2Tap() {
        openYoutubeVideo(at: 1)
    }
    
    private func openYoutubeVideo(at index: Int) {
        guard index < viewModel.latestYoutubeVideos.count else { return }
        let video = viewModel.latestYoutubeVideos[index]
        presentBottomSheet(with: video.videoURL)
    }
}
