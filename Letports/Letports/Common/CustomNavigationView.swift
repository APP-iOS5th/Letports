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
	case save
	case write
	case update
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
		case .save:
			return "저장"
		case .write:
			return "작성"
		case .update:
			return "수정"
		case .alert:
			return "bell"
		case .empty:
			return ""
		}
	}
}


enum ScreenType: Equatable {
    /// TabView Home Screen
    case largeHome
    /// TabView Gathering  Screen
    case largeGathering
    /// TabView Profile  Screen
    case largeProfile(btnName: NaviButtonType = .gear)
    /// Gathering Detail  Screen
    case smallGathering(gatheringName: String, btnName: NaviButtonType)
    /// Gathering Board Editor
    case smallBoardEditor(btnName: NaviButtonType, isUpload: Bool)
    /// Profile Detail  Screen
    case smallProfile(btnName: NaviButtonType)
    /// Gathering Setting Screen
    case smallGatheringSetting
    /// Gathering Upload, Update Screen
    case smallUploadGathering(btnName: NaviButtonType, isUpdate: Bool)
    /// Setting Screen
    case smallSetting
    /// Profile Edit
    case smallEditProfile(btnName: NaviButtonType)
    
    
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
        case .smallBoardEditor(_, let isUpload):
            return isUpload ? "게시글 작성" : "게시글 수정"
        case .smallProfile:
            return "프로필"
        case .smallGatheringSetting:
            return "소모임 관리"
        case .smallUploadGathering(_, let isUpdate):
            return isUpdate ? "소모임 수정" : "소모임 생성"
        case .smallSetting:
            return "설정"
        case .smallEditProfile:
            return "프로필 수정"
        }
    }
    
    var buttonImage: String {
        switch self {
            
        case .largeProfile(let btnName),
                .smallGathering(_, let btnName),
                .smallBoardEditor(let btnName, _),
                .smallUploadGathering(let btnName, _),
                .smallEditProfile(let btnName),
                .smallProfile(let btnName):
            return btnName.buttonName
        default:
            return ""
        }
    }

}

protocol CustomNavigationDelegate: AnyObject {
	func smallRightBtnDidTap()
	func sportsSelectBtnDidTap()
	func backBtnDidTap()
}

extension CustomNavigationDelegate {
	func smallRightBtnDidTap() {}
	func sportsSelectBtnDidTap() {}
	func backBtnDidTap() {}
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
        label.textColor = self.screenType == .largeHome ? .lpMain : .lp_black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
        label.font = self.screenType == .largeHome ? .lp_Font(.bold, size: 35) : .lp_Font(.regular, size: 35)
		label.sizeToFit()
		return label
	}()
	
	private lazy var largeRightButton: UIButton = {
		let button = UIButton()
		let title = "팀 선택"
		
		button.setTitle(title, for: .normal)
		button.titleLabel?.font = .lp_Font(.regular, size: 20)
		button.setTitleColor(.black, for: .normal)
		button.semanticContentAttribute = .forceRightToLeft
		
		button.addTarget(self, action: #selector(sportsSelectBtnDidTap), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	
	//MARK: - SMALL NavigationView Property
	
	private lazy var smallTitle: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
        label.textColor = .lp_black
		label.font = .lp_Font(.regular, size: 18)
		label.sizeToFit()
		return label
	}()
	
	private lazy var backButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(backBtnDidTap), for: .touchUpInside)
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
		
		button.titleLabel?.font = .lp_Font(.regular, size: 16)
		button.setTitleColor(.black, for: .normal)
		button.tintColor = .black
		
		button.addTarget(self, action: #selector(smallRightBtnDidTap), for: .touchUpInside)
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
	
	weak var delegate: CustomNavigationDelegate?
	
	var screenType: ScreenType = .largeGathering {
		didSet {
			setupUI()
		}
	}
	
	init(isLargeNavi: NaviSize) {
		self.isLargeNavi = isLargeNavi
		super.init(frame: .zero)
		setupUI()
	}
	
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
            largeTitle.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 8),
			largeTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            largeTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			largeTitle.heightAnchor.constraint(equalToConstant: 45),
            
			rightButtonSV.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
			rightButtonSV.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			
			largeRightButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
			largeRightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
		])
	}
	
	private func naviSmallSizeSetup() {
		self.smallTitle.text = self.screenType.title
        self.rightFirstButton.isHidden = self.screenType.buttonImage == "" ? true : false
		
		let btnImage = UIImage(systemName: self.screenType.buttonImage)
		self.rightFirstButton.setImage(btnImage, for: .normal)
		
		[smallTitle, backButton, rightButtonSV].forEach {
			self.mainView.addSubview($0)
		}
		
		//        [rightFirstButton, rightSecondButton].forEach {
		[rightFirstButton].forEach {
			rightButtonSV.addArrangedSubview($0)
		}
		
		var buttonImage = UIImage(systemName: "arrow.backward")
		switch self.screenType {
		case .smallUploadGathering:
			buttonImage = UIImage(systemName: "xmark")
		default:
			buttonImage = UIImage(systemName: "arrow.backward")
		}
		self.backButton.setImage(buttonImage, for: .normal)
		
		
		
		NSLayoutConstraint.activate([
            smallTitle.topAnchor.constraint(equalTo: self.topAnchor),
            smallTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
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
	
	
	@objc func smallRightBtnDidTap() {
		self.delegate?.smallRightBtnDidTap()
	}
	
	@objc func sportsSelectBtnDidTap() {
		self.delegate?.sportsSelectBtnDidTap()
	}
	
	@objc func backBtnDidTap() {
		self.delegate?.backBtnDidTap()
	}
	
	func rightBtnIsEnable(_ isEnable: Bool) {
		rightFirstButton.isEnabled = isEnable
		rightFirstButton.setTitleColor(rightFirstButton.isEnabled ? .lpBlack : .lpGray, for: .normal)
	}
}


