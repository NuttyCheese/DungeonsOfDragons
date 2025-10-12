//
//  MonsterListViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class MonsterListViewController: BaseViewController {
    // MARK: - Properties
    private var monstersModel = [MonsterModel]()
    private var filteredMonstersModel = [MonsterModel]()
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, MonsterModel>!
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDataSource()
        
        DataSourceRemote.shared.getMonsters { [weak self] response in
            guard let self else { return }
            monstersModel = response
            filteredMonstersModel = monstersModel
            applySnapshot(animatingDifferences: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем snapshot при возврате на экран для отображения актуального состояния избранного
        applySnapshot(animatingDifferences: false)
    }
}

extension MonsterListViewController: MonsterInfoViewControllerDelegate {
    func pressToFavoriteMonster(spell: MonsterModel, isFavorite: Bool) {
        
    }
}

extension MonsterListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let monsterModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let vc = MonsterInfoViewController(monsterModel: monsterModel)
        vc.delegate = self
        present(vc, animated: true)
    }
}
// MARK: - Diffable Data Source Setup
private extension MonsterListViewController {
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, MonsterModel>(collectionView: collectionView) { collectionView, indexPath, monster in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonsterCollectionViewCell.description(), for: indexPath) as? MonsterCollectionViewCell else {
                return UICollectionViewCell()
            }
            let isFavorite = FavoritesManager.shared.isMonsterFavorite(monster.name)
            cell.configure(data: monster, isFavorite: isFavorite)
            cell.favoriteCompletion = { data, isFavorite in
                isFavorite ? FavoritesManager.shared.addMonsterToFavorites(data.name) : FavoritesManager.shared.removeMonsterFromFavorites(data.name)
            }
            return cell
        }
    }
    
    func applySnapshot(animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MonsterModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredMonstersModel, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - Search Results Updating
extension MonsterListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredMonstersModel = monstersModel
            applySnapshot(animatingDifferences: true)
            return
        }
        
        filteredMonstersModel = monstersModel.filter {
            $0.name.lowercased().contains(searchText) || $0.pdfName.lowercased().contains(searchText)
        }
        applySnapshot(animatingDifferences: true)
    }
}

// MARK: - View Setup
private extension MonsterListViewController {
    func setupView() {
        title = "Монстры"
        setupCollectionView()
        setupSearchController()
        
        view.addSubview(collectionView)
        setupConstraints()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        let sideInset: CGFloat = 16
        let interItemSpacing: CGFloat = 16
        let totalSpacing = sideInset * 2 + interItemSpacing
        let itemWidth = (view.bounds.width - totalSpacing) / 2
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40) // 40 for label
        layout.sectionInset = UIEdgeInsets(top: 16, left: sideInset, bottom: 16, right: sideInset)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.register(MonsterCollectionViewCell.self, forCellWithReuseIdentifier: MonsterCollectionViewCell.description())
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск монстров"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
