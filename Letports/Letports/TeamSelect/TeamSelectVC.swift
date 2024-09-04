//
//  SelectTeamVC.swift
//  Letports
//
//  Created by John Yun on 8/23/24.
//


import UIKit
import Combine
import Kingfisher

class TeamSelectVC: UICollectionViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: TeamSelectVM
    weak var coordinator: TeamSelectCoordinator?
    
    enum Section: Int, CaseIterable {
        case sports, teams
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private var dataSource: DataSource!
    private lazy var selectBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("선택 완료", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 25
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(selectBtnDidTap), for: .touchUpInside)
        return btn
    }()
    
    init(viewModel: TeamSelectVM) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCV()
        configureDataSource()
        applyInitialSnapshot()
        setupSelectBtn()
        
        // UI 나중에 한번에 잡을게요.
        title = "팀 선택"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.allowsMultipleSelection = true
        
        viewModel.loadData { [weak self] in
            DispatchQueue.main.async {
                self?.updateSportsSnapshot()
                self?.updateTeamsSnapshot()
                
                
                if let firstSports = self?.viewModel.sportsCategories.first {
                    self?.viewModel.selectSports(firstSports)
                    self?.updateTeamsSnapshot()
                    
                    let firstIndexPath = IndexPath(item: 0, section: Section.sports.rawValue)
                    self?.collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: [])
                }
            }
        }
        
        viewModel.$sportsCategories
            .sink { [weak self] categories in
                self?.updateSportsSnapshot()
            }
            .store(in: &cancellables)
        
        viewModel.$filteredTeams
            .sink { [weak self] teams in
                self?.updateTeamsSnapshot()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedTeam
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateSelectBtnState()
                }
            }
            .store(in: &cancellables)
    }
    
    static func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .sports:
                return Self.createSportsSection()
            case .teams:
                return Self.createTeamsSection()
            }
        }
    }
    
    private static func createSportsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(80), heightDimension: .absolute(40))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        return section
    }
    
    private static func createTeamsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        
        return section
    }
    
    private func setupCV() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SportsCategoryCell.self, forCellWithReuseIdentifier: SportsCategoryCell.reuseIdentifier)
        collectionView.register(SportsTeamCell.self, forCellWithReuseIdentifier: SportsTeamCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            
            switch section {
            case .sports:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportsCategoryCell.reuseIdentifier, for: indexPath) as? SportsCategoryCell,
                      let sports = item as? Sports else { return nil }
                cell.configure(with: sports)
                return cell
            case .teams:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportsTeamCell.reuseIdentifier, for: indexPath) as? SportsTeamCell,
                      let team = item as? SportsTeam else { return nil }
                cell.configure(with: team)
                return cell
            }
        }
    }
    
    private func applyInitialSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.sports, .teams])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupSelectBtn() {
        view.addSubview(selectBtn)
        
        selectBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            selectBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            selectBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        updateSelectBtnState()
    }
    
    private func updateSelectBtnState() {
        let isEnabled = viewModel.selectedTeam != nil
        selectBtn.isEnabled = isEnabled
        
        if isEnabled {
            selectBtn.backgroundColor = .lpMain
            selectBtn.setTitleColor(.lpWhite, for: .normal)
        } else {
            selectBtn.backgroundColor = .lpGray
            selectBtn.setTitleColor(.lp_black, for: .normal)
        }
    }
    
    @objc private func selectBtnDidTap() {
        guard let selectedSports = viewModel.selectedSports,
              let selectedTeam = viewModel.selectedTeam else {
            return
        }
        
        viewModel.updateUserSportsAndTeam(sports: selectedSports, team: selectedTeam)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("User data updated successfully")
                    self?.coordinator?.didFinishTeamSelect(selectedTeam)
                case .failure(let error):
                    print("Failed to update user data: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    private func updateSportsSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .sports))
        snapshot.appendItems(viewModel.sportsCategories, toSection: .sports)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateTeamsSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .teams))
        snapshot.appendItems(viewModel.filteredTeams, toSection: .teams)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension TeamSelectVC {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .sports:
            guard let sports = dataSource.itemIdentifier(for: indexPath) as? Sports else { return }
            
            if let previouslySelectedIndex = viewModel.sportsCategories.firstIndex(where: { $0 == viewModel.selectedSports }) {
                let previousIndexPath = IndexPath(item: previouslySelectedIndex, section: Section.sports.rawValue)
                collectionView.deselectItem(at: previousIndexPath, animated: true)
            }
            
            
            viewModel.selectSports(sports)
            viewModel.selectTeam(nil)
            updateTeamsSnapshot()
        case .teams:
            if let team = dataSource.itemIdentifier(for: indexPath) as? SportsTeam {
                if let previouslySelectedTeam = viewModel.selectedTeam,
                   let previousIndex = viewModel.filteredTeams.firstIndex(of: previouslySelectedTeam) {
                    let previousIndexPath = IndexPath(item: previousIndex, section: Section.teams.rawValue)
                    collectionView.deselectItem(at: previousIndexPath, animated: true)
                }
                viewModel.selectTeam(team)
            }
        }
    }
}
