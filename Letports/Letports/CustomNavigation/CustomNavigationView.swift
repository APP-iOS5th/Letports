//
//  CustomNavigationView.swift
//  Letports
//
//  Created by Chung Wussup on 8/6/24.
//
import UIKit


enum NaviSize {
    /// TabView의 각 View에 해당하는 Navigation
    case large
    /// 기본 Navigation
    case small
}

enum NaviButtonType {
    case ellipsis
    case gear
    case create
    case alert
    case empty
    
    var buttonName: String {
        switch self {
        case .ellipsis:
            return "ellipsis"
        case .gear:
            return "gearshape.fill"
        case .create:
            return "생성"
        case .alert:
            return "bell"
        case .empty:
            return ""
        }
    }
}


enum ScreenType {
    /// TabView Home Screen
    case largeHome
    /// TabView Gathering  Screen
    case largeGathering
    /// TabView Profile  Screen
    case largeProfile(btnName: NaviButtonType = .gear)
    /// Gathering Detail  Screen
    case smallGathering(gatheringName: String, btnName: NaviButtonType)
    /// Profile Detail  Screen
    case samllProfile
    /// Gathering Setting Screen
    case smallGatheringSetting(btnName: NaviButtonType)
    /// Create Gathering Screen
    case smallCreateGathering(btnName: NaviButtonType)
    /// Setting Screen
    case smallSetting
    
    
    var title: String {
        switch self {
        case .largeHome:
            return "Letports"
        case .largeGathering:
            return "소모임"
        case .largeProfile:
            return "프로필"
        case .smallGathering(let gatheringName, _):
            //모임명으로 바뀌어야함
            return gatheringName
        case .samllProfile:
            return "프로필"
        case .smallGatheringSetting:
            return "소모임 설정"
        case .smallCreateGathering:
            return "소모임 생성"
        case .smallSetting:
            return "설정"
        }
    }
    
    var buttonImage: String {
        switch self {
            
        case .largeProfile(let btnName),
                .smallGathering(_, let btnName),
                .smallGatheringSetting(let btnName),
                .smallCreateGathering(let btnName):
            
            return btnName.buttonName
        default:
            return ""
        }
    }
}

protocol CustomNavigationDelegate: AnyObject {
    func smallRightButtonDidTap()
    func sportsSelectButtonDidTap()
    func backButtonDidTap()
}

extension CustomNavigationDelegate {
    func smallRightButtonDidTap() {}
    func sportsSelectButtonDidTap() {}
    func backButtonDidTap() {}
}

class CustomNavigationView: UIView {
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - LARGE NavigationView Property
    
    private lazy var largeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 35)
        label.sizeToFit()
        return label
    }()
    
    private lazy var largeRightButton: UIButton = {
        let button = UIButton()
        
        let downArrowImage = UIImage(systemName: "arrowtriangle.down.fill")
        let buttonIamge = downArrowImage?.resized(size: CGSize(width: 10, height: 10))
        button.setImage(buttonIamge, for: .normal)
        button.tintColor = .black
        
        //타이틀 바뀌어야함
        var title = "축구(FC서울)"
        let attributedText = NSMutableAttributedString(string: title)
        if let rangOpenPar = title.range(of: "("),
           let rangClosePar = title.range(of: ")") {
            let mainText = NSRange(title.startIndex..<rangOpenPar.lowerBound, in: title)
            let parText = NSRange(rangOpenPar.lowerBound..<rangClosePar.upperBound, in: title)
            
            attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: mainText)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: parText)
        }
        button.setAttributedTitle(attributedText, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        
        button.addTarget(self, action: #selector(sportsSelectButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: - SMALL NavigationView Property
    
    private lazy var smallTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 18)
        label.sizeToFit()
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var rightButtonSV: UIStackView =  {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var rightFirstButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        if let image = UIImage(systemName: self.screenType.buttonImage) {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle(self.screenType.buttonImage, for: .normal)
        }
        
        button.isHidden = self.screenType.buttonImage == "" ? true : false
        
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(smallRightButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - 네비게이션 오른쪽에 현재 버튼이 한개만들어가기떄문에 보류 - 주석
//    private lazy var rightSecondButton: UIButton = {
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
//        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
//        button.tintColor = .black
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    var isLargeNavi: NaviSize = .large {
        didSet {
            setupUI()
        }
    }
    
    var screenType: ScreenType = .largeGathering
    
    weak var delegate: CustomNavigationDelegate?
    
    init(isLargeNavi: NaviSize, screenType: ScreenType) {
        self.isLargeNavi = isLargeNavi
        self.screenType = screenType
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - UI Setup
    
    private func setupUI() {
        // 기존 서브뷰 제거
        self.subviews.forEach { $0.removeFromSuperview() }
        self.addSubview(mainView)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            rightFirstButton.heightAnchor.constraint(equalToConstant: 36),
            rightFirstButton.widthAnchor.constraint(equalToConstant: 36)
            
//            rightSecondButton.heightAnchor.constraint(equalToConstant: 36),
//            rightSecondButton.widthAnchor.constraint(equalToConstant: 36)
        ])
        
        // 높이 제약 조건 업데이트
        updateHeightConstraint(naviSize: isLargeNavi)
        naviTitleSetup(naviSize: isLargeNavi)
    }
    
    //MARK: - Navigation Height Setup
    
    private func updateHeightConstraint(naviSize: NaviSize) {
        // 기존 높이 제약 조건 제거
        self.constraints.filter { $0.firstAttribute == .height }.forEach { self.removeConstraint($0) }
        
        // 새로운 높이 제약 조건 추가
        let height: CGFloat = isLargeNavi == .large ? 90 : 44
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    
    //MARK: - Navigation Title Setup
    
    private func naviTitleSetup(naviSize: NaviSize) {
        switch naviSize {
        case .large:
            naviLargeSizeSetup()
        case .small:
            naviSmallSizeSetup()
        }
    }
    
    private func naviLargeSizeSetup() {
        self.largeTitle.text = self.screenType.title
        
        [largeTitle, rightButtonSV, largeRightButton].forEach {
            self.mainView.addSubview($0)
        }
        
        switch self.screenType {
        case .largeGathering, .largeHome:
            rightButtonSV.isHidden = true
            largeRightButton.isHidden = false
        case .largeProfile:
            rightButtonSV.isHidden = false
            largeRightButton.isHidden = true
        default: break
        }
        
        [rightFirstButton].forEach {
            rightButtonSV.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            largeTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            largeTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            rightButtonSV.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            rightButtonSV.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            largeRightButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            largeRightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    
    private func naviSmallSizeSetup() {
        self.smallTitle.text = self.screenType.title
        
        [smallTitle, backButton, rightButtonSV].forEach {
            self.mainView.addSubview($0)
        }
        
        //        [rightFirstButton, rightSecondButton].forEach {
        [rightFirstButton].forEach {
            rightButtonSV.addArrangedSubview($0)
        }
        
        var buttonImage = UIImage(systemName: "arrow.backward")
        switch self.screenType {
        case .smallCreateGathering:
            buttonImage = UIImage(systemName: "xmark")
        default:
            buttonImage = UIImage(systemName: "arrow.backward")
        }
        self.backButton.setImage(buttonImage, for: .normal)

    
        
        NSLayoutConstraint.activate([
            smallTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            smallTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 36),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            
            rightButtonSV.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightButtonSV.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    
    
    @objc func smallRightButtonDidTap() {
        self.delegate?.smallRightButtonDidTap()
    }
    
    @objc func sportsSelectButtonDidTap() {
        self.delegate?.sportsSelectButtonDidTap()
    }
    
    @objc func backButtonDidTap() {
        self.delegate?.backButtonDidTap()
    }
    
}


#Preview {
    ViewController()
}

