//
//  DiceViewController.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit
import SceneKit
import SpriteKit

struct DiceType: Hashable {
    let name: String
    let sides: Int
}

final class DiceViewController: BaseViewController {
    
    // MARK: - Properties
    private let diceTypes: [DiceType] = [
        DiceType(name: "d4", sides: 4),
        DiceType(name: "d6", sides: 6),
        DiceType(name: "d8", sides: 8),
        DiceType(name: "d10", sides: 10),
        DiceType(name: "d12", sides: 12),
        DiceType(name: "d20", sides: 20),
        DiceType(name: "d100", sides: 100)
    ]
    
    private var diceCounts: [DiceType: Int] = [:]
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, DiceType>!
    
    private var totalDiceCount: Int {
        diceCounts.values.reduce(0, +)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        setupDataSource()
        applySnapshot()
    }
    
    override func themeDidChange() {
        super.themeDidChange()
        applyStyles()
    }
}

// MARK: - View Setup
private extension DiceViewController {
    func setupView() {
        title = "Кубики"
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        let itemWidth: CGFloat = 80
        let itemHeight: CGFloat = 80
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DiceCollectionCell.self, forCellWithReuseIdentifier: DiceCollectionCell.description())
        
        view.addSubview(collectionView)
        setupConstraints()
    }
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, DiceType>(collectionView: collectionView) { [weak self] collectionView, indexPath, diceType in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiceCollectionCell.description(), for: indexPath) as? DiceCollectionCell else {
                return UICollectionViewCell()
            }
            
            let currentCount = self.diceCounts[diceType] ?? 0
            let isMaxTotalReached = self.totalDiceCount >= 6
            
            cell.configure(
                diceType: diceType,
                count: currentCount,
                isMaxTotalReached: isMaxTotalReached
            )
            
            cell.countChangedHandler = { [weak self] newCount in
                guard let self = self else { return }
                self.diceCounts[diceType] = newCount
                print("\(diceType.name): \(newCount) кубиков. Всего: \(self.totalDiceCount)")
                
                // Обновляем все видимые ячейки, чтобы обновить состояние кнопок
                self.updateVisibleCells()
            }
            
            return cell
        }
    }
    
    func updateVisibleCells() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            guard let diceType = dataSource.itemIdentifier(for: indexPath),
                  let cell = collectionView.cellForItem(at: indexPath) as? DiceCollectionCell else {
                continue
            }
            
            let currentCount = diceCounts[diceType] ?? 0
            let isMaxTotalReached = totalDiceCount >= 6
            
            cell.configure(
                diceType: diceType,
                count: currentCount,
                isMaxTotalReached: isMaxTotalReached
            )
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, DiceType>()
        snapshot.appendSections([0])
        snapshot.appendItems(diceTypes, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 152) // 120 + 16*2 (insets)
        ])
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        // Можно добавить стилизацию ячеек здесь
    }
}

// MARK: - UICollectionViewDelegate
extension DiceViewController: UICollectionViewDelegate {
    // Делегат можно использовать для дополнительной логики при необходимости
}
