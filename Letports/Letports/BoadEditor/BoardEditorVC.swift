//
//  BoardEditorVC.swift
//  Letports
//
//  Created by Chung Wussup on 8/13/24.
//

import UIKit
import Combine
import Photos

class BoardEditorVC: UIViewController {
	
	private(set) lazy var navigationView: CustomNavigationView = {
		let cnv = CustomNavigationView(isLargeNavi: .small,
									   screenType: .smallBoardEditor(btnName: viewModel.isEditMode ? .update : .write,
																	 isUpload: !viewModel.isEditMode))
		
		cnv.delegate = self
		cnv.backgroundColor = .lp_background_white
		cnv.translatesAutoresizingMaskIntoConstraints = false
		return cnv
	}()
	
	private lazy var collectionView: UICollectionView = {
		let layout = createLayout()
		let cv = UICollectionView(frame: .zero,
								  collectionViewLayout: layout)
		cv.delegate = self
		cv.dataSource = self
		cv.backgroundColor = .lp_background_white
		cv.register(BoardEditorHeaderCVCell.self,
					forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
					,withReuseIdentifier: "BoadEditorHeaderCVCell")
		cv.registersCell(cellClasses: BoardEditorPhotoCVCell.self,
						 BoardEditorTitleCVCell.self,
						 BoardEditorContentCVCell.self)
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()
	
	private lazy var loadingIndicatorView: LoadingIndicatorView = {
		let view = LoadingIndicatorView()
		view.isHidden = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	
	private var viewModel: BoardEditorVM
	
	private let buttonTapSubject = PassthroughSubject<Void, Never>()
	private var cancellables = Set<AnyCancellable>()
	
	init(viewModel: BoardEditorVM) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.setupTapGesture()
		self.bindViewModel()
		self.bindKeyboard()
		self.uploadDebounce()
	}
	
	//MARK: - Setup
	private func setupUI() {
		self.view.backgroundColor = .lp_background_white
		
		[navigationView, collectionView, loadingIndicatorView].forEach {
			self.view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			
			collectionView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			
			loadingIndicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
			loadingIndicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			loadingIndicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			loadingIndicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		])
	}
	
	private func setupTapGesture() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tapGesture.cancelsTouchesInView = false
		self.view.addGestureRecognizer(tapGesture)
	}
	
	//MARK: - Binding
	private func bindViewModel() {
		viewModel.$addButtonEnable
			.receive(on: DispatchQueue.main)
			.sink { [weak self] enable in
				self?.navigationView.rightBtnIsEnable(enable)
			}
			.store(in: &cancellables)
		
		viewModel.$boardPhotos
			.receive(on: DispatchQueue.main)
			.sink { [weak self] photos in
				self?.collectionView.reloadData()
			}
			.store(in: &cancellables)
		
		viewModel.$isUploading
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isUploading in
				if isUploading {
					self?.loadingIndicatorView.startAnimating()
				} else {
					self?.loadingIndicatorView.stopAnimating()
				}
			}
			.store(in: &cancellables)
	}
	
	private func bindKeyboard() {
		// 키보드가 나타날 때의 이벤트를 구독
		NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
			.compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
			.sink { [weak self] keyboardFrame in
				guard let self = self else { return }
				UIView.animate(withDuration: 0.3) {
					self.collectionView.contentInset = UIEdgeInsets(top: 0,
																	left: 0,
																	bottom: keyboardFrame.height,
																	right: 0)
					self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
				}
			}
			.store(in: &cancellables)
		
		// 키보드가 사라질 때의 이벤트를 구독
		NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
			.sink { [weak self] _ in
				guard let self = self else { return }
				UIView.animate(withDuration: 0.3) {
					self.collectionView.contentInset = .zero
					self.collectionView.scrollIndicatorInsets = .zero
				}
			}
			.store(in: &cancellables)
	}
	
	//MARK: - Method
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	private func uploadDebounce() {
		buttonTapSubject
			.debounce(for: .seconds(1), scheduler: RunLoop.main)
			.sink { [weak self] in
				self?.viewModel.boardUpload()
			}
			.store(in: &cancellables)
	}
	
}

extension BoardEditorVC: CustomNavigationDelegate {
	func smallRightBtnDidTap() {
		self.buttonTapSubject.send(())
	}
	
	func sportsSelectBtnDidTap() {
		
	}
	
	func backBtnDidTap() {
		self.viewModel.backButtonTapped()
	}
}

//MARK: - Compositional layout settting
extension BoardEditorVC {
	//Composition Layout 생성
	func createLayout() -> UICollectionViewCompositionalLayout {
		return UICollectionViewCompositionalLayout { sectionIndex, environment in
			switch sectionIndex {
			case 0:
				return self.createTitleSection()
			case 1:
				return self.createContentSection()
			case 2:
				return self.createHorizontalScrollSection()
			default:
				return nil
			}
		}
	}
	
	// 제목 레이아웃
	func createTitleSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											   heightDimension: .absolute(34))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .none
		section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
		
		// 섹션 헤더 설정
		section.boundarySupplementaryItems = [self.createSupplementaryHeaderItem()]
		section.supplementaryContentInsetsReference = .layoutMargins
		return section
	}
	
	// 내용 레이아웃
	func createContentSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											   heightDimension: .absolute(236))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .none
		section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
		
		// 섹션 헤더 설정
		section.boundarySupplementaryItems = [self.createSupplementaryHeaderItem()]
		section.supplementaryContentInsetsReference = .layoutMargins
		return section
	}
	
	// 사진 가로 스크롤 섹션 레이아웃
	func createHorizontalScrollSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(266),
											   heightDimension: .absolute(250))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .continuous
		section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
		
		// 섹션 헤더 설정
		section.boundarySupplementaryItems = [self.createSupplementaryHeaderItem()]
		section.supplementaryContentInsetsReference = .layoutMargins
		
		return section
	}
	
	//Header Item
	func createSupplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem{
		return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
																			 heightDimension: .estimated(43)),
														   elementKind: UICollectionView.elementKindSectionHeader,
														   alignment: .top)
	}
}

extension BoardEditorVC: UICollectionViewDelegate, UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 3
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch indexPath.section {
		case 0:
			if let cell: BoardEditorTitleCVCell = collectionView.loadCell(indexPath: indexPath) {
				cell.delegate = self
				cell.configureCell(title: self.viewModel.boardTitle)
				return cell
			}
		case 1:
			if let cell: BoardEditorContentCVCell = collectionView.loadCell(indexPath: indexPath) {
				cell.delegate = self
				cell.configureCell(content: self.viewModel.boardContents)
				return cell
			}
		case 2:
			if let cell: BoardEditorPhotoCVCell = collectionView.loadCell(indexPath: indexPath) {
				switch indexPath.row {
				case 0:
					cell.photoCellSetup(isPhoto: false)
				default:
					cell.photoCellSetup(isPhoto: true,
										photo: self.viewModel.boardPhotos[indexPath.row - 1])
				}
				cell.delegate = self
				return cell
			}
		default:
			return UICollectionViewCell()
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch section {
		case 0, 1:
			return 1
		case 2:
			return self.viewModel.getPhotoCount()
		default :
			return 1
		}
	}
	
	func collectionView(_ collectionView: UICollectionView,
						viewForSupplementaryElementOfKind kind: String,
						at indexPath: IndexPath) -> UICollectionReusableView {
		switch kind {
		case UICollectionView.elementKindSectionHeader:
			let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																		 withReuseIdentifier: "BoadEditorHeaderCVCell",
																		 for: indexPath) as! BoardEditorHeaderCVCell
			
			// 섹션별로 다른 텍스트를 설정
			switch indexPath.section {
			case 0:
				header.configureText(text: "제목")
			case 1:
				header.configureText(text: "내용")
			case 2:
				header.configureText(text: "사진", photoCount: self.viewModel.getPhotoCount() - 1)
			default:
				header.configureText(text: nil)
			}
			
			return header
		default:
			return UICollectionReusableView()
		}
	}
}

extension BoardEditorVC: BoardEditorDelegate {
	func writeTitle(content: String) {
		self.viewModel.writeBoardTitle(content: content)
	}
	
	func writeContent(content: String) {
		self.viewModel.writeBoardContents(content: content)
	}
	
	func didTapAddPhotoButton() {
		if !viewModel.photoUploadIsLimit() {
			self.viewModel.photoUploadButtonTapped()
		}  else { return }
	}
	
	func didTapDeletePhotoButton(photoIndex: Int) {
		self.viewModel.deleteBoardPhoto(index: photoIndex)
	}
}
