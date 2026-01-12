//
//  SpellListViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class SpellListViewController: BaseViewController {
    private var spellsModel = [SpellModel]()
    private var filteredSpellsModel = [SpellModel]()
    private var selectedFilters: [SpellFilterValue] = []
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var dataSource: UITableViewDiffableDataSource<Int, SpellModel>!
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchController()
        setupDataSource()
        setupActivityIndicator()
        
        activityIndicator.startAnimating()
        DataSourceRemote.shared.getSpells { [weak self] response in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            spellsModel = response
            filteredSpellsModel = spellsModel
            applySnapshot()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Применяем фильтры при возврате на экран
        if !selectedFilters.isEmpty {
            applyFilters()
        } else {
            applySnapshot()
        }
    }
}

extension SpellListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            // Применяем фильтры если они есть
            if !selectedFilters.isEmpty {
                filterSpells()
            } else {
                filteredSpellsModel = spellsModel
                applySnapshot()
            }
            return
        }
        
        // Сначала фильтруем по выбранным фильтрам
        var baseFiltered = spellsModel
        if !selectedFilters.isEmpty {
            // Группируем фильтры по категориям
            let schoolFilters = selectedFilters.compactMap { filter -> School? in
                if case .school(let school) = filter {
                    return school
                }
                return nil
            }
            
            let casterFilters = selectedFilters.compactMap { filter -> SpellCaster? in
                if case .spellCaster(let caster) = filter {
                    return caster
                }
                return nil
            }
            
            baseFiltered = spellsModel.filter { spell in
                // Проверяем школу (OR внутри категории)
                var matchesSchool = true
                if !schoolFilters.isEmpty {
                    matchesSchool = schoolFilters.contains { spell.school == $0 }
                }
                
                // Проверяем класс заклинателя (OR внутри категории)
                var matchesCaster = true
                if !casterFilters.isEmpty {
                    matchesCaster = casterFilters.contains { caster in
                        spell.spellClass?.contains { $0.name == caster } ?? false
                    }
                }
                
                // AND между категориями
                return matchesSchool && matchesCaster
            }
        }
        
        // Затем фильтруем по поисковому запросу
        filteredSpellsModel = baseFiltered.filter {
            $0.name?.lowercased().contains(searchText) ?? false || 
            $0.nameEn?.lowercased().contains(searchText) ?? false
        }
        applySnapshot()
    }
}

extension SpellListViewController: SpellInfoViewControllerDelegate {
    func pressToFavoriteSpell(spell: SpellModel, isFavorite: Bool) {
        if isFavorite {
            FavoritesManager.shared.addSpellToFavorites(spell.name ?? "")
        } else {
            FavoritesManager.shared.removeSpellFromFavorites(spell.name ?? "")
        }
        
        applySnapshot()
    }
}

extension SpellListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let spellModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let vc = SpellInfoViewController(spellModel: spellModel)
        vc.delegate = self
        present(vc, animated: true)
    }
}

private extension SpellListViewController {
    func setupView() {
        title = "Заклинания"
        setupTableView()
        
        view.subviewsOnView(tableView, activityIndicator)
        setupConstraints()
    }
    
    func setupTableView() {
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(SpellTableViewCell.self, forCellReuseIdentifier: SpellTableViewCell.description())
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск заклинаний"
        
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
        let vc = SpellFilterListViewController(spells: spellsModel, selectedFilters: selectedFilters)
        
        vc.onFiltersChanged = { [weak self] newFilters in
            guard let self = self else { return }
            self.selectedFilters = newFilters
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func applyFilters() {
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
        
        // Имитируем небольшую задержку для показа прелоадера
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.filterSpells()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func filterSpells() {
        guard !selectedFilters.isEmpty else {
            filteredSpellsModel = spellsModel
            applySnapshot()
            return
        }
        
        // Группируем фильтры по категориям
        let schoolFilters = selectedFilters.compactMap { filter -> School? in
            if case .school(let school) = filter {
                return school
            }
            return nil
        }
        
        let casterFilters = selectedFilters.compactMap { filter -> SpellCaster? in
            if case .spellCaster(let caster) = filter {
                return caster
            }
            return nil
        }
        
        filteredSpellsModel = spellsModel.filter { spell in
            // Проверяем школу (OR внутри категории)
            var matchesSchool = true
            if !schoolFilters.isEmpty {
                matchesSchool = schoolFilters.contains { spell.school == $0 }
            }
            
            // Проверяем класс заклинателя (OR внутри категории)
            var matchesCaster = true
            if !casterFilters.isEmpty {
                matchesCaster = casterFilters.contains { caster in
                    spell.spellClass?.contains { $0.name == caster } ?? false
                }
            }
            
            // AND между категориями
            return matchesSchool && matchesCaster
        }
        
        applySnapshot()
    }
    
    func setupConstraints() {
        [tableView, activityIndicator].forEach { $0.tAMIC() }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, SpellModel>(tableView: tableView) { tableView, indexPath, spell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SpellTableViewCell.description(), for: indexPath) as? SpellTableViewCell else {
                return UITableViewCell()
            }
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            let spellName = spell.name ?? ""
            let isFavorite = FavoritesManager.shared.isSpellFavorite(spellName)
            cell.confuguration(spell, isFavorite: isFavorite)
            cell.favoriteCompletion = { data, isFavorite in
                let spellName = data.name ?? ""
                if isFavorite {
                    FavoritesManager.shared.addSpellToFavorites(spellName)
                } else {
                    FavoritesManager.shared.removeSpellFromFavorites(spellName)
                }
            }
            
            return cell
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SpellModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredSpellsModel, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setupActivityIndicator() {
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
    }
}
