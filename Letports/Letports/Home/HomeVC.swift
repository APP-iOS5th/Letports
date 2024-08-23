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
    
    let teamChangeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("팀 변경", for: .normal)
        button.setTitleColor(.lpBlack, for: .normal)
        button.backgroundColor = .none
        button.layer.cornerRadius = 10
        
        button.frame = CGRect(x: 0, y: 0, width: 61, height: 22)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    lazy var profileContainerView = createBackgroundWhiteBox()
    
    lazy var teamProfileHorizontalSV = createSV(axis: .horizontal,
                                                alignment: .center,
                                                distribution: .fillProportionally,
                                                spacing: 16)
    
    lazy var teamLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 팀 이름 있는 세로 스택뷰
    lazy var teamProfileVerticalSV = createSV(axis: .vertical,
                                              alignment: .fill,
                                              distribution: .fillProportionally,
                                              spacing: 16)
    
    lazy var teamName = createLabel(text: "", fontSize: 30, fontWeight: .bold)
    
    // URL스택뷰
    lazy var urlSV = createSV(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    
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
    
    //"oo의 최신 영상"라벨
    let latestTeamVideoLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .lpBlack
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //유튜브 썸네일 흰 배경
    lazy var thumbnailContainerView = createBackgroundWhiteBox()
    
    //썸네일 전체 스택뷰
    lazy var thumbnailSV = createSV(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 20)
    
    //썸네일1 스택뷰
    lazy var firstThumbnailSV = createSV(axis: .vertical, alignment: .fill, distribution: .fillEqually, spacing: 5)
    
    //썸네일1 이미지
    lazy var firstThumbnail: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    //썸네일1 제목
    lazy var firstThumbnailTitle: UILabel = {
        let label = UILabel()
        label.text = "제목1"
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //썸네일2 스택뷰
    lazy var secondThumbnailSV = createSV(axis: .vertical, alignment: .fill, distribution: .fillEqually, spacing: 5)
    
    //썸네일2 이미지
    lazy var secondThumbnail: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    //썸네일2 제목
    lazy var secondThumbnailTitle: UILabel = {
        let label = UILabel()
        label.text = "제목2"
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //추천 소모임 뷰
    let recommendGatheringLabel: UILabel = {
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
    
    lazy var gatheringSV: UIStackView = {
        let gatheringView = createSV(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 6)
        
        return gatheringView
    }()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    //MARK: -Methods
    
    // 배경 흰 박스 만들기
    func createBackgroundWhiteBox(backgroundColor: UIColor = .white,
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
    
    //UISetting
    func setupUI() {
        view.backgroundColor = .lpBackgroundWhite
        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: teamChangeBtn)
        
        profileLayout()
        view.addSubview(latestTeamVideoLabel)
        youtubeThumbnailLayout()
        thumbnailContainerView.addSubview(thumbnailSV)
        view.addSubview(thumbnailContainerView)
        view.addSubview(recommendGatheringLabel)
        view.addSubview(gatheringScrollView)
        gatheringScrollView.addSubview(gatheringSV)
        
        layoutVC()
    }
    
    //프로필 레이아웃
    func profileLayout() {
        homeURLSV.addArrangedSubview(homeIcon)
        homeURLSV.addArrangedSubview(homeLabel)
        instagramURLSV.addArrangedSubview(instagramIcon)
        instagramURLSV.addArrangedSubview(instagramLabel)
        youtubeURLSV.addArrangedSubview(youtubeIcon)
        youtubeURLSV.addArrangedSubview(youtubeLabel)
        urlSV.addArrangedSubview(homeURLSV)
        urlSV.addArrangedSubview(instagramURLSV)
        urlSV.addArrangedSubview(youtubeURLSV)
        
        teamProfileVerticalSV.addArrangedSubview(teamName)
        teamProfileVerticalSV.addArrangedSubview(urlSV)
        
        teamProfileHorizontalSV.addArrangedSubview(teamLogo)
        teamProfileHorizontalSV.addArrangedSubview(teamProfileVerticalSV)
        
        profileContainerView.addSubview(teamProfileHorizontalSV)
        view.addSubview(profileContainerView)
        
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
    
    //썸네일 레이아웃
    func youtubeThumbnailLayout() {
        firstThumbnailSV.addArrangedSubview(firstThumbnail)
        firstThumbnailSV.addArrangedSubview(firstThumbnailTitle)
        secondThumbnailSV.addArrangedSubview(secondThumbnail)
        secondThumbnailSV.addArrangedSubview(secondThumbnailTitle)
        
        //첫번째 썸네일 탭 제스쳐
        let firstThumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail1Tap))
        firstThumbnailSV.addGestureRecognizer(firstThumbnailTapGesture)
        firstThumbnailSV.isUserInteractionEnabled = true
        
        //두번째 썸네일
        let secondThumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThumbnail2Tap))
        secondThumbnailSV.addGestureRecognizer(secondThumbnailTapGesture)
        secondThumbnailSV.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            firstThumbnail.heightAnchor.constraint(equalTo: firstThumbnailSV.heightAnchor, multiplier: 0.75),
            firstThumbnailTitle.heightAnchor.constraint(equalTo: firstThumbnailSV.heightAnchor, multiplier: 0.25),
            secondThumbnail.heightAnchor.constraint(equalTo: secondThumbnailSV.heightAnchor, multiplier: 0.75),
            secondThumbnailTitle.heightAnchor.constraint(equalTo: secondThumbnailSV.heightAnchor, multiplier: 0.25)
        ])
        
        thumbnailSV.addArrangedSubview(firstThumbnailSV)
        thumbnailSV.addArrangedSubview(secondThumbnailSV)
    }
    
    // VC레이아웃
    func layoutVC() {
        NSLayoutConstraint.activate([
            profileContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileContainerView.widthAnchor.constraint(equalToConstant: 361),
            profileContainerView.heightAnchor.constraint(equalToConstant: 110),
            
            teamProfileHorizontalSV.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 10),
            teamProfileHorizontalSV.leftAnchor.constraint(equalTo: profileContainerView.leftAnchor, constant: 10),
            teamProfileHorizontalSV.rightAnchor.constraint(equalTo: profileContainerView.rightAnchor, constant: -10),
            teamProfileHorizontalSV.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: -10),
            
            latestTeamVideoLabel.topAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: 20),
            latestTeamVideoLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            
            thumbnailContainerView.topAnchor.constraint(equalTo: latestTeamVideoLabel.bottomAnchor, constant: 20),
            thumbnailContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thumbnailContainerView.widthAnchor.constraint(equalToConstant: 361),
            thumbnailContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            thumbnailSV.topAnchor.constraint(equalTo: thumbnailContainerView.topAnchor, constant: 10),
            thumbnailSV.leftAnchor.constraint(equalTo: thumbnailContainerView.leftAnchor, constant: 30),
            thumbnailSV.widthAnchor.constraint(equalToConstant: 300),
            thumbnailSV.heightAnchor.constraint(equalToConstant: 100),
            
            recommendGatheringLabel.topAnchor.constraint(equalTo: thumbnailContainerView.bottomAnchor, constant: 20),
            recommendGatheringLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            
            gatheringScrollView.topAnchor.constraint(equalTo: recommendGatheringLabel.bottomAnchor, constant: 20),
            gatheringScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            gatheringScrollView.widthAnchor.constraint(equalToConstant: 450),
            gatheringScrollView.heightAnchor.constraint(equalToConstant: 200),
            
            gatheringSV.topAnchor.constraint(equalTo: gatheringScrollView.topAnchor),
            gatheringSV.leadingAnchor.constraint(equalTo: gatheringScrollView.leadingAnchor),
            gatheringSV.trailingAnchor.constraint(equalTo: gatheringScrollView.trailingAnchor),
            gatheringSV.bottomAnchor.constraint(equalTo: gatheringScrollView.bottomAnchor),
            gatheringSV.heightAnchor.constraint(equalTo: gatheringScrollView.heightAnchor)
        ])
    }
    
    //데이터 바인딩
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
                self.latestTeamVideoLabel.text = "\(team.teamName ?? "")의 최신 영상"
            }
            .store(in: &cancellables)
        
        viewModel.$latestYoutubeVideos
            .sink { [weak self] videos in
                guard let self = self else { return }
                
                if let video1 = videos.first {
                    self.firstThumbnail.kf.setImage(with: video1.thumbnailURL)
                    self.firstThumbnailTitle.text = video1.title
                    self.firstThumbnail.tag = 0
                }
                
                if videos.count > 1 {
                    let video2 = videos[1]
                    self.secondThumbnail.kf.setImage(with: video2.thumbnailURL)
                    self.secondThumbnailTitle.text = video2.title
                    self.secondThumbnail.tag = 1
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
    
    //썸네일 이미지 업로드
    private func updateGatheringImages(_ gatherings: [Gathering]) {
        gatheringSV.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gatherings.forEach { gathering in
            if let url = gathering.gatherImage {
                // 컨테이너 뷰 생성
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                containerView.widthAnchor.constraint(equalToConstant: 300).isActive = true
                containerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
                
                // 이미지 뷰 생성 및 추가
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.kf.setImage(with: url)
                imageView.layer.cornerRadius = 10
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(imageView)
                
                // 이름 라벨 생성 및 추가
                if let gatherName = gathering.gatherName {
                    let nameLabel = UILabel()
                    nameLabel.text = gatherName
                    nameLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
                    nameLabel.textColor = .white
                    nameLabel.textAlignment = .center
                    nameLabel.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(nameLabel)
                    
                    // 이름 라벨 레이아웃 설정
                    NSLayoutConstraint.activate([
                        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
                        nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
                        nameLabel.heightAnchor.constraint(equalToConstant: 40)
                    ])
                }
                
                // 이미지 뷰 레이아웃 설정
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])
                
                // 컨테이너 뷰를 stackView에 추가
                gatheringSV.addArrangedSubview(containerView)
            }
        }
    }
    
    //url 탭 바텀시트
    func presentBottomSheet(with url: URL) {
        let bottomSheetVC = URLVC(url: url)
        bottomSheetVC.modalPresentationStyle = .pageSheet
        
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(bottomSheetVC, animated: true, completion: nil)
    }
    
    //유튜브 썸네일 오픈
    private func openYoutubeVideo(at index: Int) {
        guard index < viewModel.latestYoutubeVideos.count else { return }
        let video = viewModel.latestYoutubeVideos[index]
        presentBottomSheet(with: video.videoURL)
    }
    
    //MARK: -Objc Methods
    //url 탭 액션
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
    
    //썸네일 탭 액션
    @objc func handleThumbnail1Tap() {
        openYoutubeVideo(at: 0)
    }
    
    @objc func handleThumbnail2Tap() {
        openYoutubeVideo(at: 1)
    }
}
