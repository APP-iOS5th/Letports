//
//  GatheringDetailVC.swift
//  Letports
//
//  Created by Yachae on 8/12/24.
//

import UIKit

class GatheringDetailVC: UIViewController {
	weak var coordinator: GatheringCoordinator?
	private let scrollView = UIScrollView()
	private let contentView = UIView()
	private var isExpanded = true
	private var backgroundViewHeightConstraint: NSLayoutConstraint!
	private let gatheringDescript = UITextView()
	private var textHeight = 0.0
	private let toggleButton = UIButton(type: .system)
	private let customNavi = CustomNavigationView(
		isLargeNavi: .small,
		screenType: .smallGathering(gatheringName: "수호단", btnName: .gear))
	
	let boardTV = UITableView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		setupCustomNavi()
		setupScrollView()
		setupContents()
		gatheringDescript.layoutIfNeeded()
		adjustBackgroundViewHeight()
	}
	
	// 커스텀 네비 오토레이아웃
	func setupCustomNavi() {
		view.addSubview(customNavi)
		customNavi.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			customNavi.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			customNavi.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
			customNavi.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			customNavi.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
	
	func setupScrollView() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		navigationController?.hidesBarsOnSwipe = true
		view.addSubview(scrollView)
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: customNavi.bottomAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		NSLayoutConstraint.activate([
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])
	}

	// MARK: - 컨텐츠 stackView
	
	func setupContents() {
		let gatheringImage: UIImageView = {
			let imageView = UIImageView()
			imageView.image = UIImage(named: "SampleImage.png")
			imageView.contentMode = .scaleAspectFill
			imageView.translatesAutoresizingMaskIntoConstraints = false
			return imageView
		}()
		
		let gatheringName: UILabel = {
			let label = UILabel()
			label.text = "모임 이름"
			label.font = UIFont.systemFont(ofSize: 15)
			return label
		}()
		
		let gatherMaster: UILabel = {
			let label = UILabel()
			label.text = "모임장: 매드카우"
			label.font = UIFont.systemFont(ofSize: 15)
			return label
		}()
		
		let currentPersonLabel: UILabel = {
			let label = UILabel()
			label.text = "현재인원 : 1 / 10"
			label.font = UIFont.systemFont(ofSize: 15)
			return label
		}()
		
		let titleSV: UIStackView = {
			let stackView = UIStackView(arrangedSubviews: [gatheringName, gatherMaster, currentPersonLabel])
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.axis = .vertical
			stackView.spacing = 5
			return stackView
		}()
		
		let titleLine: UIView = {
			let line = UIView()
			line.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
			line.translatesAutoresizingMaskIntoConstraints = false
			return line
		}()
		
		let backgroundView: UIView = {
			let backgroundView = UIView()
			backgroundView.backgroundColor = .white
			backgroundView.layer.cornerRadius = 10
			backgroundView.clipsToBounds = true
			backgroundView.translatesAutoresizingMaskIntoConstraints = false
			return backgroundView
		}()
		
		gatheringInfo()
		
		toggleButton.setTitle("▲", for: .normal)
		toggleButton.translatesAutoresizingMaskIntoConstraints = false
		toggleButton.addTarget(self, action: #selector(toggleGatheringInfo), for: .touchUpInside)
		
		let profileCV = GatheringDetailProfileCV(profiles: profiles)
		
		let profileLine: UIView = {
			let line = UIView()
			line.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
			line.translatesAutoresizingMaskIntoConstraints = false
			return line
		}()
		
		let allBoardButton: UIButton = {
			let button = UIButton(type: .system)
			button.setTitle("전체", for: .normal)
			button.backgroundColor = .systemBlue
			button.setTitleColor(.black, for: .normal)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.addTarget(self, action: #selector(allBoardButtonTap), for: .touchUpInside)
			return button
		}()
		
		let noticeBoardButton: UIButton = {
			let button = UIButton(type: .system)
			button.setTitle("공지", for: .normal)
			button.backgroundColor = .systemGreen
			button.setTitleColor(.black, for: .normal)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.addTarget(self, action: #selector(noticeButtonTap), for: .touchUpInside)
			return button
		}()
		
		let freeBoardButton: UIButton = {
			let button = UIButton(type: .system)
			button.setTitle("자유게시판", for: .normal)
			button.backgroundColor = .systemRed
			button.setTitleColor(.black, for: .normal)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.addTarget(self, action: #selector(freeBoardButtonTap), for: .touchUpInside)
			return button
		}()
		
		// 게시판 버튼 스택 뷰
		let boardButtonSV: UIStackView = {
			let stackView = UIStackView(arrangedSubviews: [allBoardButton, noticeBoardButton, freeBoardButton])
			stackView.axis = .horizontal
			stackView.distribution = .fillEqually
			stackView.spacing = 10
			stackView.translatesAutoresizingMaskIntoConstraints = false
			return stackView
		}()
		
		let boardLine: UIView = {
			let line = UIView()
			line.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
			line.translatesAutoresizingMaskIntoConstraints = false
			return line
		}()
		
		let boardTV = GatheringDetailBoardTV(board: allBoard)
		
		contentView.addSubview(gatheringImage)
		contentView.addSubview(titleSV)
		contentView.addSubview(titleLine)
		contentView.addSubview(backgroundView)
		contentView.addSubview(toggleButton)
		backgroundView.addSubview(gatheringDescript)
		contentView.addSubview(profileCV)
		contentView.addSubview(profileLine)
		contentView.addSubview(boardButtonSV)
		contentView.addSubview(boardLine)
		contentView.addSubview(boardTV)
		
		// MARK: - 컨텐츠 오토레이아웃
		NSLayoutConstraint.activate([
			gatheringImage.topAnchor.constraint(equalTo: contentView.topAnchor),
			gatheringImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			gatheringImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			gatheringImage.heightAnchor.constraint(equalToConstant: 200),
			
			titleSV.topAnchor.constraint(equalTo: gatheringImage.bottomAnchor, constant: 20),
			titleSV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			titleSV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			titleSV.heightAnchor.constraint(equalToConstant: 70),
			
			titleLine.heightAnchor.constraint(equalToConstant: 1),
			titleLine.topAnchor.constraint(equalTo: titleSV.bottomAnchor, constant: 4),
			titleLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			titleLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			backgroundView.topAnchor.constraint(equalTo: titleLine.bottomAnchor, constant: 20),
			backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			gatheringDescript.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
			gatheringDescript.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
			gatheringDescript.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),
			gatheringDescript.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),
			
			toggleButton.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 10),
			toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			
			profileCV.topAnchor.constraint(equalTo: toggleButton.bottomAnchor),
			profileCV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			profileCV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			profileCV.heightAnchor.constraint(equalToConstant: 120),
			profileCV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
			
			profileLine.heightAnchor.constraint(equalToConstant: 1),
			profileLine.topAnchor.constraint(equalTo: profileCV.bottomAnchor, constant: 4),
			profileLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			profileLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			boardButtonSV.topAnchor.constraint(equalTo: profileLine.bottomAnchor, constant: 10),
			boardButtonSV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			boardButtonSV.heightAnchor.constraint(equalToConstant: 30),
			
			boardLine.topAnchor.constraint(equalTo: boardButtonSV.bottomAnchor, constant: 10),
			boardLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			boardLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			boardLine.heightAnchor.constraint(equalToConstant: 1),
			
			boardTV.topAnchor.constraint(equalTo: boardLine.bottomAnchor, constant: 10),
			boardTV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			boardTV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			boardTV.heightAnchor.constraint(equalToConstant: 400)
		])
		
		backgroundViewHeightConstraint = gatheringDescript.heightAnchor.constraint(equalToConstant: textHeight)
		backgroundViewHeightConstraint.isActive = true
		
		adjustBackgroundViewHeight()
	}
	
	func gatheringInfo() {
		gatheringDescript.text = """
  🖤❤️ 수호신은 FC 서울을 응원하는 서포터즈 🖤❤️
  
  ⚽️🏟️주로 골대 뒤에서 응원을 하지만  👩‍❤️‍👨FC 서울을 응원하고 사랑한다면 누구든 수호신
  
  ✅ 가입대상
  ☝️️ 서울을 사랑한다면 👌
  ✌️ 혼자가기 고민했다면 👌
  
  ✅ 가입 조건
  ☝️️ 개랑, 매북, 통산, 싸천, 징구, 빵집, 남패 금지🚫🚯
  """
		gatheringDescript.textColor = .black
		gatheringDescript.backgroundColor = .clear
		gatheringDescript.font = UIFont.systemFont(ofSize: 15)
		gatheringDescript.isEditable = false
		gatheringDescript.isScrollEnabled = false
		gatheringDescript.translatesAutoresizingMaskIntoConstraints = false
	}
	
	// 모임소개 UITextView 높이 자동조절
	func adjustBackgroundViewHeight() {
		textHeight = gatheringDescript.sizeThatFits(
			CGSize(width: gatheringDescript.bounds.width,
				   height: CGFloat.greatestFiniteMagnitude)).height
		backgroundViewHeightConstraint.constant = textHeight
	}
	
	// MARK: - 버튼 동작
	// 모임소개 접기 버튼
	@objc func toggleGatheringInfo() {
		isExpanded.toggle()
		textHeight = gatheringDescript.sizeThatFits(
			CGSize(width: gatheringDescript.bounds.width,
				   height: CGFloat.greatestFiniteMagnitude)).height
		backgroundViewHeightConstraint.constant = isExpanded ? textHeight : 100
		
		toggleButton.setTitle(isExpanded ? "▲" : "▼", for: .normal)
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	@objc func allBoardButtonTap() {
		print("전체버튼이 눌렸습니다.")
	}
	
	@objc func noticeButtonTap() {
		print("공지버튼이 눌렸습니다.")
	}
	
	@objc func freeBoardButtonTap() {
		print("자유게시판버튼이 눌렸습니다.")
	}
}


#Preview {
	GatheringDetailVC()
}
