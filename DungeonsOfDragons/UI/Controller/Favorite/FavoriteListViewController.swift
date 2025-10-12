//
//  FavoriteListViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class FavoriteListViewController: BaseViewController {
    // MARK: - Properties
    private var monstersModel = [MonsterModel]()
    private var spellsModel = [SpellModel]()
    
    private var favoriteMonsters = [MonsterModel]()
    private var favoriteSpells = [SpellModel]()
    
    private let segmentControl = UISegmentedControl(items: ["Монстры", "Заклинания"])
    private var collectionView: UICollectionView!
    private var tableView: UITableView!
    
    private var monsterDataSource: UICollectionViewDiffableDataSource<Int, MonsterModel>!
    private var spellDataSource: UITableViewDiffableDataSource<Int, SpellModel>!
    
    private let emptyLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavorites()
    }
    
    // MARK: - Private Methods
    private func loadData() {
        // Загружаем все данные монстров и заклинаний
        DataSourceRemote.shared.getMonsters { [weak self] response in
            guard let self else { return }
            self.monstersModel = response
            self.updateFavorites()
        }
        
        DataSourceRemote.shared.getSpells { [weak self] response in
            guard let self else { return }
            self.spellsModel = response
            self.updateFavorites()
        }
    }
    
    private func updateFavorites() {
        // Получаем имена избранных из UserDefaults
        let favoriteMonsterNames = FavoritesManager.shared.getFavoriteMonsters()
        let favoriteSpellNames = FavoritesManager.shared.getFavoriteSpells()
        
        // Фильтруем полученные данные по избранным
        favoriteMonsters = monstersModel.filter { favoriteMonsterNames.contains($0.name) }
        favoriteSpells = spellsModel.filter { favoriteSpellNames.contains($0.name ?? "") }
        
        // Обновляем UI
        updateSegmentControlVisibility()
        updateVisibleContent()
    }
    
    private func updateSegmentControlVisibility() {
        // Показываем сегмент контрол только если оба массива не пустые
        let shouldShowSegment = !favoriteMonsters.isEmpty && !favoriteSpells.isEmpty
        segmentControl.isHidden = !shouldShowSegment
        
        // Если показываем сегмент контрол, выбираем первый сегмент по умолчанию
        if shouldShowSegment && segmentControl.selectedSegmentIndex == UISegmentedControl.noSegment {
            segmentControl.selectedSegmentIndex = 0
        }
    }
    
    private func updateVisibleContent() {
        let hasMonsters = !favoriteMonsters.isEmpty
        let hasSpells = !favoriteSpells.isEmpty
        
        if !hasMonsters && !hasSpells {
            // Нет избранных вообще
            showEmptyState()
        } else if hasMonsters && hasSpells {
            // Есть оба типа - показываем выбранный в сегменте
            hideEmptyState()
            if segmentControl.selectedSegmentIndex == 0 {
                showMonsters()
            } else {
                showSpells()
            }
        } else if hasMonsters {
            // Только монстры
            hideEmptyState()
            showMonsters()
        } else {
            // Только заклинания
            hideEmptyState()
            showSpells()
        }
    }
    
    private func showMonsters() {
        collectionView.isHidden = false
        tableView.isHidden = true
        applyMonsterSnapshot()
    }
    
    private func showSpells() {
        collectionView.isHidden = true
        tableView.isHidden = false
        applySpellSnapshot()
    }
    
    private func showEmptyState() {
        collectionView.isHidden = true
        tableView.isHidden = true
        emptyLabel.isHidden = false
    }
    
    private func hideEmptyState() {
        emptyLabel.isHidden = true
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateVisibleContent()
    }
}

// MARK: - Collection View Delegate
extension FavoriteListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let monsterModel = monsterDataSource.itemIdentifier(for: indexPath) else { return }
        // Обработка нажатия на монстра
    }
}

// MARK: - Table View Delegate
extension FavoriteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let spellModel = spellDataSource.itemIdentifier(for: indexPath) else { return }
        // Обработка нажатия на заклинание
    }
}

// MARK: - Data Source Setup
private extension FavoriteListViewController {
    func setupMonsterDataSource() {
        monsterDataSource = UICollectionViewDiffableDataSource<Int, MonsterModel>(collectionView: collectionView) { collectionView, indexPath, monster in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonsterCollectionViewCell.description(), for: indexPath) as? MonsterCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(data: monster, isFavorite: true)
            cell.favoriteCompletion = { [weak self] data, isFavorite in
                guard let self else { return }
                if isFavorite {
                    FavoritesManager.shared.addMonsterToFavorites(data.name)
                } else {
                    FavoritesManager.shared.removeMonsterFromFavorites(data.name)
                }
                // Обновляем список избранных
                self.updateFavorites()
            }
            return cell
        }
    }
    
    func setupSpellDataSource() {
        spellDataSource = UITableViewDiffableDataSource<Int, SpellModel>(tableView: tableView) { tableView, indexPath, spell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SpellTableViewCell.description(), for: indexPath) as? SpellTableViewCell else {
                return UITableViewCell()
            }
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.confuguration(spell, isFavorite: true)
            cell.favoriteCompletion = { [weak self] data, isFavorite in
                guard let self else { return }
                let spellName = data.name ?? ""
                if isFavorite {
                    FavoritesManager.shared.addSpellToFavorites(spellName)
                } else {
                    FavoritesManager.shared.removeSpellFromFavorites(spellName)
                }
                // Обновляем список избранных
                self.updateFavorites()
            }
            return cell
        }
    }
    
    func applyMonsterSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MonsterModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(favoriteMonsters, toSection: 0)
        monsterDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySpellSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SpellModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(favoriteSpells, toSection: 0)
        spellDataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - View Setup
private extension FavoriteListViewController {
    func setupView() {
        title = "Избранное"
        
        setupSegmentControl()
        setupCollectionView()
        setupTableView()
        setupEmptyLabel()
        setupMonsterDataSource()
        setupSpellDataSource()
        
        view.subviewsOnView(segmentControl, collectionView, tableView, emptyLabel)
        setupConstraints()
    }
    
    func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentControl.isHidden = true
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
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        layout.sectionInset = UIEdgeInsets(top: 16, left: sideInset, bottom: 16, right: sideInset)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.register(MonsterCollectionViewCell.self, forCellWithReuseIdentifier: MonsterCollectionViewCell.description())
        collectionView.backgroundColor = .clear
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(SpellTableViewCell.self, forCellReuseIdentifier: SpellTableViewCell.description())
        tableView.isHidden = true
    }
    
    func setupEmptyLabel() {
        emptyLabel.text = "Нет избранных элементов"
        emptyLabel.textColor = .white
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyLabel.isHidden = true
    }
    
    func setupConstraints() {
        [segmentControl, collectionView, tableView, emptyLabel].forEach { $0.tAMIC() }
        
        NSLayoutConstraint.activate([
            // Segment Control
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty Label
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
