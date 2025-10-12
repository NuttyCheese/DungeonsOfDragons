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
}

extension SpellListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredSpellsModel = spellsModel
            applySnapshot()
            return
        }
        
        filteredSpellsModel = spellsModel.filter {
            $0.name?.lowercased().contains(searchText) ?? false || (($0.nameEn?.lowercased().contains(searchText)) != nil)
        }
        applySnapshot()
    }
}

//extension SpellListViewController: SpellViewControllerDelegate {
//    func pressToFavoriteSpell(spell: SpellModel, isFavorite: Bool) {
//        // Обработка избранного
//    }
//}

extension SpellListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let spellModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
//        let vc = SpellViewController(spellModel: spellModel)
//        vc.delegate = self
//        present(vc, animated: true)
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
        definesPresentationContext = true
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
            cell.confuguration(spell, isFavorite: false)
            cell.favoriteCompletion = { [weak self] data, isFavorite in
                guard let self else { return }
                // Обработка избранного
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
