//
//  GatheringBoardDetailVC.swift
//  Letports
//
//  Created by Yachae on 8/19/24.
//

import UIKit
import Combine

final class GatheringBoardDetailVC: UIViewController {
    
    private lazy var navigationView: CustomNavigationView = {
        let cnv = CustomNavigationView(isLargeNavi: .small,
                                       screenType: .smallGathering(gatheringName: "자유게시판", btnName: .ellipsis))
        
        cnv.delegate = self
        cnv.backgroundColor = .lp_background_white
        cnv.translatesAutoresizingMaskIntoConstraints = false
        return cnv
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.backgroundColor = .lp_background_white
        tv.dataSource = self
        tv.delegate = self
        tv.registersCell(cellClasses: GatheringBoardDetailProfileTVCell.self,
                         GatheringBoardDetailContentTVCell.self,
                         SeperatorLineTVCell.self,
                         GatheringBoardDetailImagesTVCell.self,
                         CommentHeaderLabelTVCell.self,
                         CommentTVCell.self)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()
    
    private lazy var commentInputView: CommentInputView = {
        let view = CommentInputView()
        view.delegate = self
        view.backgroundColor = .lpBackgroundWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingIndicatorView: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private var viewModel: GatheringBoardDetailVM
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: GatheringBoardDetailVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindKeyboard()
        bindViewModel()
        setupTapGesture()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.getPost()
		if let boardType = viewModel.boardPost?.boardType {
			updateUI(with: boardType)
		}
    }
    
    private func bindViewModel() {
        Publishers.Merge(
            viewModel.$boardPost.map { _ in () },
            viewModel.$commentsWithUsers.map {_ in ()}
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)
        
        viewModel.$isLoading
            .sink { [weak self] isUploading in
                if isUploading {
                    self?.loadingIndicatorView.startAnimating()
                } else {
                    self?.loadingIndicatorView.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with boardType: PostType) {
        let gatheringName: String
        
        switch boardType {
        case .free:
            gatheringName = "자유게시판"
        case .noti:
            gatheringName = "공지게시판"
        case .all:
            gatheringName = "전체게시판"
        }
        
        let screenType: ScreenType = .smallGathering(gatheringName: gatheringName, btnName: .ellipsis)
        
        navigationView.screenType = screenType
        tableView.reloadData()
        self.view.setNeedsLayout()
    }
    
    // MARK: - setupUI()
    private func setupUI() {
        self.view.backgroundColor = .lp_background_white
        
        [navigationView, tableView, commentInputView, loadingIndicatorView].forEach {
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentInputView.topAnchor),
            
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            commentInputView.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            
        ])
    }
    
    private func bindKeyboard() {
        // 키보드가 나타날 때의 이벤트를 구독
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink { [weak self] keyboardFrame in
                guard let self = self else { return }
                
                let bottomSafeArea = self.view.safeAreaInsets.bottom
                let yOffset = keyboardFrame.height - bottomSafeArea
                
                UIView.animate(withDuration: 0.3) {
                    self.commentInputView.transform = CGAffineTransform(translationX: 0, y: -yOffset)
                    self.tableView.contentInset = UIEdgeInsets(top: 0,
                                                               left: 0,
                                                               bottom: keyboardFrame.height,
                                                               right: 0)
                    self.tableView.scrollIndicatorInsets = self.tableView.contentInset
                }
            }
            .store(in: &cancellables)
        
        // 키보드가 사라질 때의 이벤트를 구독
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.commentInputView.transform = .identity
                    self.tableView.contentInset = .zero
                    self.tableView.scrollIndicatorInsets = .zero
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.view)
        let tappedView = self.view.hitTest(location, with: nil)
        
        if !(tappedView?.isDescendant(of: commentInputView) ?? false) {
            dismissKeyboard()
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}

extension GatheringBoardDetailVC: CustomNavigationDelegate {
    func smallRightBtnDidTap() {
        viewModel.naviRightBtnDidTap()
    }
    func backBtnDidTap() {
        viewModel.boardDetailBackBtnTap()
    }
}

extension GatheringBoardDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.getBoardDetailCellTypes()[indexPath.row] {
        case .boardProfileTitle:
            if let cell: GatheringBoardDetailProfileTVCell = tableView.loadCell(indexPath: indexPath) {
                if let userInfo = viewModel.getUserInfoForCurrentPost() {
                    let createDate = viewModel.getPostDate()
                    cell.configure(nickname: userInfo.nickname, imageUrl: userInfo.imageUrl, creatDate: createDate)
                }
                return cell
            }
        case .boardContents:
            if let cell: GatheringBoardDetailContentTVCell  = tableView.loadCell(indexPath: indexPath) {
				if let post = viewModel.boardPost {
					cell.configure(with: post)
				}
                return cell
            }
        case .separator:
            if let cell: SeperatorLineTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configureCell(height: 1)
                return cell
            }
        case .images:
            if let cell: GatheringBoardDetailImagesTVCell = tableView.loadCell(indexPath: indexPath)  {
                cell.post = viewModel.boardPost
                return cell
            }
        case .commentHeaderLabel:
            if let cell: CommentHeaderLabelTVCell = tableView.loadCell(indexPath: indexPath) {
                return cell
            }
        case .commentEmpty:
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.textLabel?.text = "댓글이 없어요.."
            cell.textLabel?.textAlignment = .center
			cell.textLabel?.font = UIFont.lp_Font(.regular, size: 16)
            cell.textLabel?.textColor = .gray
            cell.backgroundColor = .lp_background_white
            return cell
        case .comment(let comment):
            if let cell: CommentTVCell = tableView.loadCell(indexPath: indexPath) {
                if let commentWithUser = viewModel.commentsWithUsers.first(where: { $0.comment.commentUID == comment.commentUID }) {
                    cell.configureCell(with: commentWithUser.user, comment: commentWithUser.comment)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getBoardDetailCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension GatheringBoardDetailVC: CommentInputDelegate {
    func didTapAddComment(comment: String) {
        viewModel.addComment(comment: comment) {
            self.commentInputView.clearText()
            self.viewModel.getPost()
            
            let lastSection = self.tableView.numberOfSections - 1
            let lastRow = self.tableView.numberOfRows(inSection: lastSection) - 1
            let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
}
