//
//  FilterCategorySelectionViewController.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 12.01.2026.
//

import UIKit

final class FilterCategorySelectionViewController<FilterValueType: Filterable>: BaseViewController, UITableViewDelegate, UISearchResultsUpdating {
    // MARK: - Properties
    private let categoryTitle: String
    private var allOptions: [FilterValueType] = []
    private var filteredOptions: [FilterValueType] = []
    private var selectedOptions: Set<FilterValueType> = []
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var dataSource: UITableViewDiffableDataSource<Int, FilterValueType>!
    
    var onSelectionChanged: (([FilterValueType]) -> Void)?
    
    // MARK: - Initialization
    init(categoryTitle: String, options: [FilterValueType], selectedOptions: [FilterValueType] = []) {
        self.categoryTitle = categoryTitle
        self.allOptions = options
        self.filteredOptions = options
        self.selectedOptions = Set(selectedOptions)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchController()
        setupTableView()
        setupDataSource()
        applySnapshot()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let option = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
        
        // Обновляем snapshot с анимацией для визуального обновления чекбоксов
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([option])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        // Немедленно уведомляем об изменении
        onSelectionChanged?(Array(selectedOptions))
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredOptions = allOptions
            applySnapshot()
            return
        }
        
        filteredOptions = allOptions.filter {
            $0.filterDisplayName.lowercased().contains(searchText)
        }
        applySnapshot()
    }
}


// MARK: - Private Methods
private extension FilterCategorySelectionViewController {
    func setupView() {
        title = categoryTitle
        view.subviewsOnView(tableView)
        setupConstraints()
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.searchBarStyle = .minimal
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorColor = .white
        tableView.register(FilterSelectionCell.self, forCellReuseIdentifier: FilterSelectionCell.description())
    }
    
    func setupConstraints() {
        tableView.tAMIC()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, FilterValueType>(tableView: tableView) { [weak self] tableView, indexPath, option in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterSelectionCell.description(), for: indexPath) as? FilterSelectionCell else {
                return UITableViewCell()
            }
            
            let isSelected = self?.selectedOptions.contains(option) ?? false
            cell.configure(with: option.filterDisplayName, isSelected: isSelected)
            
            return cell
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, FilterValueType>()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredOptions, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
