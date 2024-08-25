//
//  SelectTeamVC.swift
//  Letports
//
//  Created by John Yun on 8/23/24.
//


import UIKit
import Combine
import Kingfisher

class TeamSelectionViewController: UICollectionViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = TeamSelectionViewModel()
    
    enum Section: Int, CaseIterable {
        case sports, teams
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private var dataSource: DataSource!
    
    init() {
        super.init(collectionViewLayout: Self.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TeamSelectionViewController - viewDidLoad called")
        setupCollectionView()
        configureDataSource()
        applyInitialSnapshot()
        setupSelectButton()
        
        title = "팀 선택"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        viewModel.loadData { [weak self] in
            print("Data loading completed")
            DispatchQueue.main.async {
                self?.updateSportsSnapshot()
                self?.updateTeamsSnapshot()
            }
        }
        
        viewModel.$sportsCategories
            .sink { [weak self] categories in
                print("Sports categories updated: \(categories.count)")

                self?.updateSportsSnapshot()
            }
            .store(in: &cancellables)
        
        viewModel.$filteredTeams
            .sink { [weak self] teams in
                print("Filtered teams updated: \(teams.count)")
                self?.updateTeamsSnapshot()
            }
            .store(in: &cancellables)
    }
    
    private static func createLayout() -> UICollectionViewLayout {
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
        
        return section
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SportsCell.self, forCellWithReuseIdentifier: SportsCell.reuseIdentifier)
        collectionView.register(TeamCell.self, forCellWithReuseIdentifier: TeamCell.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            
            switch section {
            case .sports:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportsCell.reuseIdentifier, for: indexPath) as? SportsCell,
                      let sports = item as? TeamSelectionViewModel.Sports else { return nil }
                cell.configure(with: sports)
                return cell
            case .teams:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCell.reuseIdentifier, for: indexPath) as? TeamCell,
                      let team = item as? TeamSelectionViewModel.Team else { return nil }
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
    
    private func setupSelectButton() {
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("선택 완료", for: .normal)
        selectButton.backgroundColor = .systemBlue
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.layer.cornerRadius = 25
        view.addSubview(selectButton)
        
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            selectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }
    
    @objc private func selectButtonTapped() {
        print("선택 완료 버튼이 탭되었습니다.")
        // TODO: 선택된 팀 처리 로직 구현
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

extension TeamSelectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .sports:
            guard let sports = dataSource.itemIdentifier(for: indexPath) as? TeamSelectionViewModel.Sports else { return }
            viewModel.selectSports(sports)
            updateTeamsSnapshot()
        case .teams:
            if let team = dataSource.itemIdentifier(for: indexPath) as? TeamSelectionViewModel.Team {
                print("Selected team: \(team.name), TeamUID: \(team.teamUID), Sports: \(team.sports)")
                // TODO: 선택된 팀 처리 로직 구현
            }
        }
    }
}
