//
//  SelectTeamVC.swift
//  Letports
//
//  Created by John Yun on 8/23/24.
//

import UIKit

class TeamSelectionViewController: UICollectionViewController {
    enum Section: Int, CaseIterable {
        case categories, teams
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    private var dataSource: DataSource!
    private let viewModel = TeamSelectionViewModel()
    
    init() {
        super.init(collectionViewLayout: Self.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureDataSource()
        applyInitialSnapshot()
        setupSelectButton()
        
        title = "팀 선택"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private static func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .categories:
                return Self.createCategoriesSection()
            case .teams:
                return Self.createTeamsSection()
            }
        }
    }
    
    private static func createCategoriesSection() -> NSCollectionLayoutSection {
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
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.register(TeamCell.self, forCellWithReuseIdentifier: TeamCell.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            
            switch section {
            case .categories:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell,
                      let category = item as? TeamSelectionViewModel.Category else { return nil }
                cell.configure(with: category)
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
        snapshot.appendSections([.categories, .teams])
        snapshot.appendItems(viewModel.categories, toSection: .categories)
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
    }
}

extension TeamSelectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .categories:
            guard let category = dataSource.itemIdentifier(for: indexPath) as? TeamSelectionViewModel.Category else { return }
            viewModel.selectCategory(category)
            updateTeamsSnapshot()
        case .teams:
            print("선택된 팀: \(viewModel.filteredTeams[indexPath.item].name)")
        }
    }
    
    private func updateTeamsSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .teams))
        snapshot.appendItems(viewModel.filteredTeams, toSection: .teams)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
