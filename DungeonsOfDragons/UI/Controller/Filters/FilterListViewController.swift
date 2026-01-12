//
//  FilterListViewController.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 12.01.2026.
//

import UIKit

// MARK: - Filterable Protocol
protocol Filterable: Hashable {
    var filterDisplayName: String { get }
}

// MARK: - Section Enum
enum FilterSection: Int, CaseIterable, Hashable {
    case selected = 0
    case categories = 1
    
    var title: String {
        switch self {
        case .selected:
            return "Выбранные фильтры"
        case .categories:
            return "Категории фильтров"
        }
    }
}

// MARK: - Filter List View Controller для монстров
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
    
    private func setupNavigationBar() {
        let resetButton = UIBarButtonItem(
            title: "Сбросить",
            style: .plain,
            target: self,
            action: #selector(resetFilters)
        )
        navigationItem.rightBarButtonItem = resetButton
    }
    
    @objc private func resetFilters() {
        selectedFilters.removeAll()
        applySnapshot()
        onFiltersChanged?(selectedFilters)
    }
    
    private func setupCategories() {
        categories = [.biom, .cha, .size, .type, .skill, .exp, .cr, .ac, .hp, .speed, .alignment, .str, .dex, .con, .intilect, .wis, .chaStat]
    }
    
    private func matchesCategory(_ category: MonsterFilterCategory, filter: MonsterFilterValue) -> Bool {
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

// MARK: - CategoryCell
final class CategoryCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

private extension CategoryCell {
    func setupView() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .white
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.subviewsOnView(titleLabel, arrowImageView)
        setupConstraints()
    }
    
    func setupConstraints() {
        [titleLabel, arrowImageView].forEach { $0.tAMIC() }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -16),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

// MARK: - SelectedFilterCell (Овальная ячейка с минусом)
final class SelectedFilterCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let removeButton = UIButton(type: .system)
    private var removeAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        removeAction = nil
        removeButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        removeButton.tintColor = .white
        removeButton.isEnabled = true
    }
    
    func configure(with title: String, removeAction: @escaping () -> Void) {
        titleLabel.text = title
        self.removeAction = removeAction
        removeButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
    }
    
    @objc private func removeButtonTapped() {
        removeAction?()
    }
}

private extension SelectedFilterCell {
    func setupView() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
        
        setupLabel()
        setupButton()
        
        contentView.subviewsOnView(titleLabel, removeButton)
        setupConstraints()
    }
    
    func setupLabel() {
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byClipping
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.allowsDefaultTighteningForTruncation = false
    }
    
    func setupButton() {
        removeButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        removeButton.tintColor = .white
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        [titleLabel, removeButton].forEach { $0.tAMIC() }
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

// MARK: - Filter List View Controller для заклинаний
final class SpellFilterListViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    private var categories: [SpellFilterCategory] = []
    private var selectedFilters: [SpellFilterValue] = []
    private var spells: [SpellModel] = []
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<FilterSection, AnyHashable>!
    
    var onFiltersChanged: (([SpellFilterValue]) -> Void)?
    
    // MARK: - Initialization
    init(spells: [SpellModel], selectedFilters: [SpellFilterValue] = []) {
        self.spells = spells
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
    func getSelectedFilters() -> [SpellFilterValue] {
        return selectedFilters
    }
    
    private func setupNavigationBar() {
        let resetButton = UIBarButtonItem(
            title: "Сбросить",
            style: .plain,
            target: self,
            action: #selector(resetFilters)
        )
        navigationItem.rightBarButtonItem = resetButton
    }
    
    @objc private func resetFilters() {
        selectedFilters.removeAll()
        applySnapshot()
        onFiltersChanged?(selectedFilters)
    }
    
    private func setupCategories() {
        categories = [.school, .spellCaster, .components, .range, .castingTime, .duration, .level]
    }
    
    private func matchesCategory(_ category: SpellFilterCategory, filter: SpellFilterValue) -> Bool {
        switch (category, filter) {
        case (.school, .school), (.spellCaster, .spellCaster),
             (.components, .components), (.range, .range),
             (.castingTime, .castingTime), (.duration, .duration),
             (.level, .level):
            return true
        default:
            return false
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == FilterSection.categories.rawValue,
              let category = dataSource.itemIdentifier(for: indexPath) as? SpellFilterCategory else {
            return
        }
        
        let availableValues = spells.getAvailableFilterValues(for: category)
        let selectedValues = selectedFilters.filter { filter in
            matchesCategory(category, filter: filter)
        }
        
        let selectionVC = FilterCategorySelectionViewController<SpellFilterValue>(
            categoryTitle: category.categoryTitle,
            options: availableValues,
            selectedOptions: selectedValues
        )
        
        selectionVC.onSelectionChanged = { [weak self] newSelections in
            guard let self = self else { return }
            
            self.selectedFilters.removeAll { filter in
                self.matchesCategory(category, filter: filter)
            }
            
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
            if let filter = dataSource.itemIdentifier(for: indexPath) as? SpellFilterValue {
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

// MARK: - Private Methods для SpellFilterListViewController
private extension SpellFilterListViewController {
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
                guard let filter = item as? SpellFilterValue,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedFilterCell.description(), for: indexPath) as? SelectedFilterCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: filter.filterDisplayName) { [weak self] in
                    self?.removeFilter(filter)
                }
                return cell
                
            case .categories:
                guard let category = item as? SpellFilterCategory,
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
    
    func removeFilter(_ filter: SpellFilterValue) {
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

// MARK: - SectionHeaderView
final class SectionHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

private extension SectionHeaderView {
    func setupView() {
        backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        
        addSubview(titleLabel)
        titleLabel.tAMIC()
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
