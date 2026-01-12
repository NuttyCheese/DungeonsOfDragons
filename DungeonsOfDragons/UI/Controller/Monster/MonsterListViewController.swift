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
    private var selectedFilters: [MonsterFilterValue] = []
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, MonsterModel>!
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        // Применяем фильтры при возврате на экран
        if !selectedFilters.isEmpty {
            applyFilters()
        } else {
            applySnapshot(animatingDifferences: false)
        }
    }
}

extension MonsterListViewController: MonsterInfoViewControllerDelegate {
    func pressToFavoriteMonster(monster: MonsterModel, isFavorite: Bool) {
        if isFavorite {
            FavoritesManager.shared.addMonsterToFavorites(monster.name)
        } else {
            FavoritesManager.shared.removeMonsterFromFavorites(monster.name)
        }
        
        applySnapshot(animatingDifferences: true)
    }
}

extension MonsterListViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        collectionView.reloadData()
    }
}

extension MonsterListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let monsterModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let vc = MonsterInfoViewController(monsterModel: monsterModel)
        vc.delegate = self
        vc.presentationController?.delegate = self
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
            // Применяем фильтры если они есть
            if !selectedFilters.isEmpty {
                filterMonsters()
            } else {
                filteredMonstersModel = monstersModel
                applySnapshot(animatingDifferences: true)
            }
            return
        }
        
        // Сначала фильтруем по выбранным фильтрам
        var baseFiltered = monstersModel
        if !selectedFilters.isEmpty {
            // Группируем фильтры по категориям
            let biomFilters = selectedFilters.compactMap { filter -> Biom? in
                if case .biom(let biom) = filter {
                    return biom
                }
                return nil
            }
            
            let chaFilters = selectedFilters.compactMap { filter -> Cha? in
                if case .cha(let cha) = filter {
                    return cha
                }
                return nil
            }
            
            let sizeFilters = selectedFilters.compactMap { filter -> Size? in
                if case .size(let size) = filter {
                    return size
                }
                return nil
            }
            
            let typeFilters = selectedFilters.compactMap { filter -> TypeEnum? in
                if case .type(let type) = filter {
                    return type
                }
                return nil
            }
            
            baseFiltered = monstersModel.filter { monster in
                // Проверяем биомы (OR внутри категории)
                var matchesBiom = true
                if !biomFilters.isEmpty {
                    matchesBiom = biomFilters.contains { monster.bioms.contains($0) }
                }
                
                // Проверяем характеристики (OR внутри категории)
                var matchesCha = true
                if !chaFilters.isEmpty {
                    matchesCha = chaFilters.contains { cha in
                        monster.str == cha || monster.dex == cha || monster.con == cha ||
                        monster.intilect == cha || monster.wis == cha || monster.cha == cha
                    }
                }
                
                // Проверяем размер (OR внутри категории)
                var matchesSize = true
                if !sizeFilters.isEmpty {
                    matchesSize = sizeFilters.contains { monster.size == $0 }
                }
                
                // Проверяем тип (OR внутри категории)
                var matchesType = true
                if !typeFilters.isEmpty {
                    matchesType = typeFilters.contains { monster.type == $0 }
                }
                
                // AND между категориями
                return matchesBiom && matchesCha && matchesSize && matchesType
            }
        }
        
        // Затем фильтруем по поисковому запросу
        filteredMonstersModel = baseFiltered.filter {
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
        setupActivityIndicator()
        
        view.addSubview(collectionView)
        setupConstraints()
    }
    
    func setupActivityIndicator() {
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
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
        
        let rightButtonItem = UIBarButtonItem.init(
              title: "Фильтр",
              style: .plain,
              target: self,
              action: #selector(rightButtonAction)
        )
        
        navigationItem.rightBarButtonItem = rightButtonItem
        
        definesPresentationContext = true
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        let vc = MonsterFilterListViewController(monsters: monstersModel, selectedFilters: selectedFilters)
        
        vc.onFiltersChanged = { [weak self] newFilters in
            guard let self = self else { return }
            self.selectedFilters = newFilters
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func applyFilters() {
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.tAMIC()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Имитируем небольшую задержку для показа прелоадера
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.filterMonsters()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    func filterMonsters() {
        guard !selectedFilters.isEmpty else {
            filteredMonstersModel = monstersModel
            applySnapshot(animatingDifferences: true)
            return
        }
        
        // Группируем фильтры по категориям
        let biomFilters = selectedFilters.compactMap { filter -> Biom? in
            if case .biom(let biom) = filter {
                return biom
            }
            return nil
        }
        
        let chaFilters = selectedFilters.compactMap { filter -> Cha? in
            if case .cha(let cha) = filter {
                return cha
            }
            return nil
        }
        
        let sizeFilters = selectedFilters.compactMap { filter -> Size? in
            if case .size(let size) = filter {
                return size
            }
            return nil
        }
        
        let typeFilters = selectedFilters.compactMap { filter -> TypeEnum? in
            if case .type(let type) = filter {
                return type
            }
            return nil
        }
        
        filteredMonstersModel = monstersModel.filter { monster in
            // Проверяем биомы (OR внутри категории)
            var matchesBiom = true
            if !biomFilters.isEmpty {
                matchesBiom = biomFilters.contains { monster.bioms.contains($0) }
            }
            
            // Проверяем характеристики (OR внутри категории)
            var matchesCha = true
            if !chaFilters.isEmpty {
                matchesCha = chaFilters.contains { cha in
                    monster.str == cha || monster.dex == cha || monster.con == cha ||
                    monster.intilect == cha || monster.wis == cha || monster.cha == cha
                }
            }
            
            // Проверяем размер (OR внутри категории)
            var matchesSize = true
            if !sizeFilters.isEmpty {
                matchesSize = sizeFilters.contains { monster.size == $0 }
            }
            
            // Проверяем тип (OR внутри категории)
            var matchesType = true
            if !typeFilters.isEmpty {
                matchesType = typeFilters.contains { monster.type == $0 }
            }
            
            // AND между категориями
            return matchesBiom && matchesCha && matchesSize && matchesType
        }
        
        applySnapshot(animatingDifferences: true)
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
