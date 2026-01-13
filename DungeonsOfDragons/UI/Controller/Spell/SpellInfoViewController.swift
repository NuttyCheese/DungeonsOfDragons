//
//  SpellInfoViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

protocol SpellInfoViewControllerDelegate: AnyObject {
    func pressToFavoriteSpell(spell: SpellModel, isFavorite: Bool)
}

final class SpellInfoViewController: BaseViewController {
    private let spellModel: SpellModel
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let favoriteButton = UIButton(type: .system)
    private var dataSource: UITableViewDiffableDataSource<Int, String>!
    
    weak var delegate: SpellInfoViewControllerDelegate?
    
    // MARK: - Initializer
    init(spellModel: SpellModel) {
        self.spellModel = spellModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupFavoriteButton()
        updateFavoriteButtonState()
        configureDataSource()
        applySnapshot()
        applyStyles()
    }
    
    override func themeDidChange() {
        super.themeDidChange()
        applyStyles()
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        
        favoriteButton.setImage(
            UIImage(systemName: "star")?.withTintColor(style.iconColor, renderingMode: .alwaysOriginal),
            for: .normal
        )
        favoriteButton.setImage(
            UIImage(systemName: "star.fill")?.withTintColor(style.accentColor, renderingMode: .alwaysOriginal),
            for: .selected
        )
        
        // Обновляем ячейки
        tableView.reloadData()
    }
}

// MARK: - Private Methods
private extension SpellInfoViewController {
    func setupView() {
        view.addSubview(tableView)
        
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupFavoriteButton() {
        favoriteButton.tintColor = .clear
        favoriteButton.addTarget(self, action: #selector(iconButtonTapped), for: .touchUpInside)

        view.addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configureDataSource() {
        let style = DesignManager.shared.getCurrentStyle()
        dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) { tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = row
            cell.selectionStyle = .none
            cell.backgroundColor = style.secondaryBackgroundColor
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = style.primaryTextColor
            return cell
        }
        
        dataSource.defaultRowAnimation = .fade
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        let sections = visibleSections
        
        for (index, section) in sections.enumerated() {
            snapshot.appendSections([index])
            snapshot.appendItems(section.rows, toSection: index)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func updateFavoriteButtonState() {
        let spellName = spellModel.name ?? ""
        let isFavorite = FavoritesManager.shared.isSpellFavorite(spellName)
        favoriteButton.isSelected = isFavorite
    }
    
    @objc private func iconButtonTapped() {
        favoriteButton.isSelected.toggle()
        UIView.transition(with: favoriteButton, duration: 0.3, options: .transitionFlipFromRight) { [weak self] in
            guard let self else { return }
            let spellName = self.spellModel.name ?? ""
            if self.favoriteButton.isSelected {
                FavoritesManager.shared.addSpellToFavorites(spellName)
            } else {
                FavoritesManager.shared.removeSpellFromFavorites(spellName)
            }
            self.delegate?.pressToFavoriteSpell(spell: self.spellModel, isFavorite: self.favoriteButton.isSelected)
        }
    }
}

// MARK: - UITableViewDelegate
extension SpellInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < visibleSections.count else { return nil }
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let label = UILabel()
        label.text = visibleSections[section].title
        let style = DesignManager.shared.getCurrentStyle()
        label.textColor = style.primaryTextColor
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

// MARK: - Section Setup
private extension SpellInfoViewController {
    struct Section {
        let title: String
        let rows: [String]
    }

    var visibleSections: [Section] {
        var sections: [Section] = []

        if let name = spellModel.name, !name.isEmpty {
            sections.append(Section(title: "Название", rows: [name]))
        }

        if let school = spellModel.school, !school.isEmpty {
            sections.append(Section(title: "Школа магии", rows: [school]))
        }

        if let level = spellModel.level, !level.isEmpty {
            sections.append(Section(title: "Уровень", rows: [level]))
        }

        if let castingTime = spellModel.castingTime, !castingTime.isEmpty {
            sections.append(Section(title: "Время накладывания", rows: [castingTime]))
        }

        if let range = spellModel.range, !range.isEmpty {
            sections.append(Section(title: "Дальность", rows: [range]))
        }

        if let components = spellModel.components, !components.isEmpty {
            sections.append(Section(title: "Компоненты", rows: [components]))
        }

        if let duration = spellModel.duration, !duration.isEmpty {
            sections.append(Section(title: "Длительность", rows: [duration]))
        }

        if let text = spellModel.text, !text.isEmpty {
            sections.append(Section(title: "Описание", rows: [text]))
        }

        if let spellClasses = spellModel.spellClass, !spellClasses.isEmpty {
            let classes = spellClasses.compactMap { $0.name }
            if !classes.isEmpty {
                sections.append(Section(title: "Классы", rows: classes))
            }
        }

        return sections
    }
}
