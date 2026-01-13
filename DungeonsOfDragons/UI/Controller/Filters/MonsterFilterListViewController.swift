//
//  MonsterFilterListViewController.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit

final class MonsterFilterListViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    private var categories: [MonsterFilterCategory] = []
    private var selectedFilters: [MonsterFilterValue] = []
    private var monsters: [MonsterModel] = []
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<FilterSection, AnyHashable>!
    
    var onFiltersChanged: (([MonsterFilterValue]) -> Void)?
    
    // MARK: - Initialization
    init(monsters: [MonsterModel], selectedFilters: [MonsterFilterValue] = []) {
        self.monsters = monsters
        self.selectedFilters = selectedFilters
        super.init(nibName: nil, bundle: nil)
        setupCategories()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupView()
        setupDataSource()
        setupNavigationBar()
        applySnapshot()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Применяем фильтры при уходе с экрана
        if isMovingFromParent {
            onFiltersChanged?(selectedFilters)
        }
    }
    
    // MARK: - Public Methods
    func getSelectedFilters() -> [MonsterFilterValue] {
        return selectedFilters
    }
    
    @objc private func resetFilters() {
        selectedFilters.removeAll()
        applySnapshot()
        onFiltersChanged?(selectedFilters)
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == FilterSection.categories.rawValue,
              let category = dataSource.itemIdentifier(for: indexPath) as? MonsterFilterCategory else {
            return
        }
        
        // Получаем доступные значения для этой категории из моделей
        let availableValues = monsters.getAvailableFilterValues(for: category)
        let selectedValues = selectedFilters.filter { filter in
            matchesCategory(category, filter: filter)
        }
        
        // Открываем экран выбора
        let selectionVC = FilterCategorySelectionViewController<MonsterFilterValue>(
            categoryTitle: category.categoryTitle,
            options: availableValues,
            selectedOptions: selectedValues
        )
        
        selectionVC.onSelectionChanged = { [weak self] newSelections in
            guard let self = self else { return }
            
            // Удаляем старые фильтры этой категории
            self.selectedFilters.removeAll { filter in
                self.matchesCategory(category, filter: filter)
            }
            
            // Добавляем новые выбранные фильтры
            self.selectedFilters.append(contentsOf: newSelections)
            self.applySnapshot()
            self.onFiltersChanged?(self.selectedFilters)
        }
        
        navigationController?.pushViewController(selectionVC, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = FilterSection(rawValue: indexPath.section) else {
            return CGSize.zero
        }
        
        switch section {
        case .selected:
            if let filter = dataSource.itemIdentifier(for: indexPath) as? MonsterFilterValue {
                let text = filter.filterDisplayName
                let font = UIFont.systemFont(ofSize: 14, weight: .medium)
                
                let textAttributes: [NSAttributedString.Key: Any] = [.font: font]
                let textSize = (text as NSString).boundingRect(
                    with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: textAttributes,
                    context: nil
                ).size
                
                let textWidth = ceil(textSize.width)
                let cellWidth = 12 + textWidth + 8 + 24 + 8
                let maxWidth = max(collectionView.bounds.width - 32, 100)
                let finalWidth = min(cellWidth, maxWidth)
                
                return CGSize(width: finalWidth, height: 36)
            }
            return CGSize(width: 100, height: 36)
        case .categories:
            return CGSize(width: collectionView.bounds.width - 32, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard let sectionType = FilterSection(rawValue: section) else {
            return 8
        }
        return sectionType == .selected ? 8 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
}

// MARK: - Private Methods
private extension MonsterFilterListViewController {
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(SelectedFilterCell.self, forCellWithReuseIdentifier: SelectedFilterCell.description())
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.description())
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.description())
    }
    
    func setupView() {
        title = "Фильтры"
        view.subviewsOnView(collectionView)
        setupConstraints()
    }
    
    func setupConstraints() {
        collectionView.tAMIC()
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<FilterSection, AnyHashable>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self else {
                return UICollectionViewCell()
            }
            
            let section = FilterSection(rawValue: indexPath.section)
            
            switch section {
            case .selected:
                guard let filter = item as? MonsterFilterValue,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedFilterCell.description(), for: indexPath) as? SelectedFilterCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: filter.filterDisplayName) { [weak self] in
                    self?.removeFilter(filter)
                }
                return cell
                
            case .categories:
                guard let category = item as? MonsterFilterCategory,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.description(), for: indexPath) as? CategoryCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: category.categoryTitle)
                return cell
                
            case .none:
                return UICollectionViewCell()
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.description(),
                for: indexPath
            ) as? SectionHeaderView,
            let section = FilterSection(rawValue: indexPath.section) else {
                return UICollectionReusableView()
            }
            
            header.configure(with: section.title)
            return header
        }
    }
    
    func matchesCategory(_ category: MonsterFilterCategory, filter: MonsterFilterValue) -> Bool {
        switch (category, filter) {
        case (.biom, .biom), (.cha, .cha), (.size, .size), (.type, .type),
             (.skill, .skill), (.exp, .exp), (.cr, .cr), (.ac, .ac),
             (.hp, .hp), (.speed, .speed), (.alignment, .alignment),
             (.str, .str), (.dex, .dex), (.con, .con), (.intilect, .intilect),
             (.wis, .wis), (.chaStat, .chaStat):
            return true
        default:
            return false
        }
    }
    
    func setupCategories() {
        categories = [.biom, .cha, .size, .type, .skill, .exp, .cr, .ac, .hp, .speed, .alignment, .str, .dex, .con, .intilect, .wis, .chaStat]
    }
    
    func setupNavigationBar() {
        let resetButton = UIBarButtonItem(
            title: "Сбросить",
            style: .plain,
            target: self,
            action: #selector(resetFilters)
        )
        navigationItem.rightBarButtonItem = resetButton
    }
    
    func removeFilter(_ filter: MonsterFilterValue) {
        selectedFilters.removeAll { $0 == filter }
        applySnapshot()
        onFiltersChanged?(selectedFilters)
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<FilterSection, AnyHashable>()
        
        snapshot.appendSections([.selected])
        if !selectedFilters.isEmpty {
            snapshot.appendItems(selectedFilters, toSection: .selected)
        }
        
        snapshot.appendSections([.categories])
        snapshot.appendItems(categories, toSection: .categories)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
