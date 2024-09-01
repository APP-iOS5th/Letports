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
        viewModel.getBoardData()
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
    }
    
    
    // MARK: - setupUI()
    private func setupUI() {
        self.view.backgroundColor = .lp_background_white
        
        [navigationView, tableView, commentInputView].forEach {
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
            commentInputView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindKeyboard() {
        // 키보드가 나타날 때의 이벤트를 구독
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink { [weak self] keyboardFrame in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.commentInputView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height)
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
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
            guard let cell: GatheringBoardDetailProfileTVCell = tableView.loadCell(indexPath: indexPath) else {
                return UITableViewCell()
            }
            if let userInfo = viewModel.getUserInfoForCurrentPost() {
                cell.configure(nickname: userInfo.nickname, imageUrl: userInfo.imageUrl)
            }
            return cell
        case .boardContents:
            if let cell: GatheringBoardDetailContentTVCell  = tableView.loadCell(indexPath: indexPath) {
                let post = viewModel.boardPost
                cell.configure(with: post)
                return cell
            }
        case .separator:
            if let cell: SeperatorLineTVCell = tableView.loadCell(indexPath: indexPath) {
                cell.configureCell(height: 1)
                return cell
            }
        case .images:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatheringBoardDetailImagesTVCell",
                                                           for: indexPath) as? GatheringBoardDetailImagesTVCell else {
                return UITableViewCell()
            }
            cell.post = viewModel.boardPost
            return cell
            
        case .commentHeaderLabel:
            if let cell: CommentHeaderLabelTVCell = tableView.loadCell(indexPath: indexPath) {
                return cell
            }
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
}
extension GatheringBoardDetailVC: CommentInputDelegate {
    func addComment(comment: String) {
        viewModel.addComment(comment: comment) {
            self.commentInputView.clearText()
            self.viewModel.getBoardData()
            
            let lastIndex = IndexPath(row: self.tableView.numberOfRows(inSection: self.tableView.numberOfSections - 1) - 1,
                                      section: self.tableView.numberOfSections - 1)
            self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
        }
    }
}
