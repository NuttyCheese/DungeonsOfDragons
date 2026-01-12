//
//  MonsterInfoViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

protocol MonsterInfoViewControllerDelegate: AnyObject {
    func pressToFavoriteMonster(monster: MonsterModel, isFavorite: Bool)
}

final class MonsterInfoViewController: BaseViewController {
    private let monsterModel: MonsterModel
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var dataSource: UITableViewDiffableDataSource<Section, Row>!
    
    weak var delegate: MonsterInfoViewControllerDelegate?
    
    init(monsterModel: MonsterModel) {
        self.monsterModel = monsterModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDataSource()
        applySnapshot()
    }
}

private extension MonsterInfoViewController {
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(MonsterImageTableViewCell.self, forCellReuseIdentifier: MonsterImageTableViewCell.description())
        tableView.register(MonsterDetailTableViewCell.self, forCellReuseIdentifier: MonsterDetailTableViewCell.description())
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Row>(tableView: tableView) { [weak self] tableView, indexPath, row in
            guard let self else { return UITableViewCell() }
            switch row {
                case .image(let url):
                    let cell = tableView.dequeueReusableCell(withIdentifier: MonsterImageTableViewCell.description(), for: indexPath) as! MonsterImageTableViewCell
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    let isFavorite = FavoritesManager.shared.isMonsterFavorite(self.monsterModel.name)
                    cell.configure(with: url, isFavorite: isFavorite)
                    cell.favoriteCompletion = { [weak self] isFavorite in
                        guard let self else { return }
                        if isFavorite {
                            FavoritesManager.shared.addMonsterToFavorites(self.monsterModel.name)
                        } else {
                            FavoritesManager.shared.removeMonsterFromFavorites(self.monsterModel.name)
                        }
                        self.delegate?.pressToFavoriteMonster(monster: self.monsterModel, isFavorite: isFavorite)
                    }
                    return cell
                case .detail(let title, let value):
                    let cell = tableView.dequeueReusableCell(withIdentifier: MonsterDetailTableViewCell.description(), for: indexPath) as! MonsterDetailTableViewCell
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    cell.configure(title: title, value: value)
                    return cell
            }
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        
        // Add image section
        snapshot.appendSections([.image])
        snapshot.appendItems([.image(monsterModel.imgStaticURL)])
        
        // Add details section
        snapshot.appendSections([.details])
        snapshot.appendItems([
            .detail("Имя", monsterModel.name),
            .detail("Размер", monsterModel.size.rawValue),
            .detail("Тип", monsterModel.type.rawValue),
            .detail("Моральное лицо", monsterModel.alignment),
            .detail("Класс брони", monsterModel.ac),
            .detail("Очки здоровья", monsterModel.hp),
            .detail("Скорость", monsterModel.speed),
            .detail("Языки", monsterModel.languages.joined(separator: ", ")),
            .detail("Рейтинг сложности", monsterModel.cr)
        ])
        
        // Add traits section
        if !monsterModel.monsterTrait.isEmpty {
            snapshot.appendSections([.traits])
            let traits = monsterModel.monsterTrait.map { Row.detail($0.name, $0.text) }
            snapshot.appendItems(traits)
        }
        
        // Add actions section
        if !monsterModel.monsterAction.isEmpty {
            snapshot.appendSections([.actions])
            let actions = monsterModel.monsterAction.map { Row.detail($0.name, $0.text) }
            snapshot.appendItems(actions)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

private extension MonsterInfoViewController {
    enum Section: Int, Hashable {
        case image
        case details
        case traits
        case actions
    }
    
    enum Row: Hashable {
        case image(String)
        case detail(String, String)
    }
}
