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
            baseFiltered = filterMonstersArray(monstersModel, with: selectedFilters)
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
        
        filteredMonstersModel = filterMonstersArray(monstersModel, with: selectedFilters)
        applySnapshot(animatingDifferences: true)
    }
    
    func filterMonstersArray(_ monsters: [MonsterModel], with filters: [MonsterFilterValue]) -> [MonsterModel] {
        guard !filters.isEmpty else {
            return monsters
        }
        
        // Группируем фильтры по категориям
        let biomFilters = filters.compactMap { filter -> String? in
            if case .biom(let biom) = filter {
                return biom
            }
            return nil
        }
        
        let chaFilters = filters.compactMap { filter -> String? in
            if case .cha(let cha) = filter {
                return cha
            }
            return nil
        }
        
        let sizeFilters = filters.compactMap { filter -> String? in
            if case .size(let size) = filter {
                return size
            }
            return nil
        }
        
        let typeFilters = filters.compactMap { filter -> String? in
            if case .type(let type) = filter {
                return type
            }
            return nil
        }
        
        let skillFilters = filters.compactMap { filter -> String? in
            if case .skill(let skill) = filter {
                return skill
            }
            return nil
        }
        
        let expFilters = filters.compactMap { filter -> String? in
            if case .exp(let exp) = filter {
                return exp
            }
            return nil
        }
        
        let crFilters = filters.compactMap { filter -> String? in
            if case .cr(let cr) = filter {
                return cr
            }
            return nil
        }
        
        let acFilters = filters.compactMap { filter -> String? in
            if case .ac(let ac) = filter {
                return ac
            }
            return nil
        }
        
        let hpFilters = filters.compactMap { filter -> String? in
            if case .hp(let hp) = filter {
                return hp
            }
            return nil
        }
        
        let speedFilters = filters.compactMap { filter -> String? in
            if case .speed(let speed) = filter {
                return speed
            }
            return nil
        }
        
        let alignmentFilters = filters.compactMap { filter -> String? in
            if case .alignment(let alignment) = filter {
                return alignment
            }
            return nil
        }
        
        let strFilters = filters.compactMap { filter -> String? in
            if case .str(let str) = filter {
                return str
            }
            return nil
        }
        
        let dexFilters = filters.compactMap { filter -> String? in
            if case .dex(let dex) = filter {
                return dex
            }
            return nil
        }
        
        let conFilters = filters.compactMap { filter -> String? in
            if case .con(let con) = filter {
                return con
            }
            return nil
        }
        
        let intilectFilters = filters.compactMap { filter -> String? in
            if case .intilect(let intilect) = filter {
                return intilect
            }
            return nil
        }
        
        let wisFilters = filters.compactMap { filter -> String? in
            if case .wis(let wis) = filter {
                return wis
            }
            return nil
        }
        
        let chaStatFilters = filters.compactMap { filter -> String? in
            if case .chaStat(let chaStat) = filter {
                return chaStat
            }
            return nil
        }
        
        return monsters.filter { monster in
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
            
            // Проверяем навыки (OR внутри категории)
            var matchesSkill = true
            if !skillFilters.isEmpty {
                matchesSkill = skillFilters.contains { monster.skill.contains($0) }
            }
            
            // Проверяем опыт (OR внутри категории)
            var matchesExp = true
            if !expFilters.isEmpty {
                matchesExp = expFilters.contains { monster.exp == $0 }
            }
            
            // Проверяем рейтинг сложности (OR внутри категории)
            var matchesCr = true
            if !crFilters.isEmpty {
                matchesCr = crFilters.contains { monster.cr == $0 }
            }
            
            // Проверяем класс брони (OR внутри категории)
            var matchesAc = true
            if !acFilters.isEmpty {
                matchesAc = acFilters.contains { monster.ac == $0 }
            }
            
            // Проверяем здоровье (OR внутри категории)
            var matchesHp = true
            if !hpFilters.isEmpty {
                matchesHp = hpFilters.contains { monster.hp == $0 }
            }
            
            // Проверяем скорость (OR внутри категории)
            var matchesSpeed = true
            if !speedFilters.isEmpty {
                matchesSpeed = speedFilters.contains { monster.speed == $0 }
            }
            
            // Проверяем мировоззрение (OR внутри категории)
            var matchesAlignment = true
            if !alignmentFilters.isEmpty {
                matchesAlignment = alignmentFilters.contains { monster.alignment == $0 }
            }
            
            // Проверяем силу (OR внутри категории)
            var matchesStr = true
            if !strFilters.isEmpty {
                matchesStr = strFilters.contains { monster.str == $0 }
            }
            
            // Проверяем ловкость (OR внутри категории)
            var matchesDex = true
            if !dexFilters.isEmpty {
                matchesDex = dexFilters.contains { monster.dex == $0 }
            }
            
            // Проверяем телосложение (OR внутри категории)
            var matchesCon = true
            if !conFilters.isEmpty {
                matchesCon = conFilters.contains { monster.con == $0 }
            }
            
            // Проверяем интеллект (OR внутри категории)
            var matchesIntilect = true
            if !intilectFilters.isEmpty {
                matchesIntilect = intilectFilters.contains { monster.intilect == $0 }
            }
            
            // Проверяем мудрость (OR внутри категории)
            var matchesWis = true
            if !wisFilters.isEmpty {
                matchesWis = wisFilters.contains { monster.wis == $0 }
            }
            
            // Проверяем харизму (OR внутри категории)
            var matchesChaStat = true
            if !chaStatFilters.isEmpty {
                matchesChaStat = chaStatFilters.contains { monster.cha == $0 }
            }
            
            // AND между категориями
            return matchesBiom && matchesCha && matchesSize && matchesType && matchesSkill &&
                   matchesExp && matchesCr && matchesAc && matchesHp && matchesSpeed &&
                   matchesAlignment && matchesStr && matchesDex && matchesCon &&
                   matchesIntilect && matchesWis && matchesChaStat
        }
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
