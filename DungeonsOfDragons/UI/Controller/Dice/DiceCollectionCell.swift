//
//  DiceCollectionCell.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit

final class DiceCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let nameLabel = UILabel()
    private let minusButton = CircleButton()
    private let countLabel = UILabel()
    private let plusButton = CircleButton()
    
    private var currentCount: Int = 0 {
        didSet {
            updateCountLabel()
            updateButtonsState()
        }
    }
    
    private var isMaxTotalReached: Bool = false
    
    var countChangedHandler: ((Int) -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(diceType: DiceType, count: Int = 0, isMaxTotalReached: Bool = false) {
        nameLabel.text = diceType.name
        self.isMaxTotalReached = isMaxTotalReached
        currentCount = count
        updateButtonsState()
    }
    
    func getCurrentCount() -> Int {
        return currentCount
    }
}

// MARK: - Actions
private extension DiceCollectionCell {
    @objc func minusButtonTapped() {
        guard currentCount > 0 else { return }
        currentCount -= 1
        countChangedHandler?(currentCount)
    }
    
    @objc func plusButtonTapped() {
        guard currentCount < 6, !isMaxTotalReached else { return }
        currentCount += 1
        countChangedHandler?(currentCount)
    }
    
    func updateCountLabel() {
        countLabel.text = "\(currentCount)"
    }
    
    func updateButtonsState() {
        minusButton.isEnabled = currentCount > 0
        plusButton.isEnabled = currentCount < 6 && !isMaxTotalReached
        
        let style = DesignManager.shared.getCurrentStyle()
        minusButton.alpha = minusButton.isEnabled ? 1.0 : 0.5
        plusButton.alpha = plusButton.isEnabled ? 1.0 : 0.5
    }
}

// MARK: - View Setup
private extension DiceCollectionCell {
    func setupView() {
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .systemBlue
        
        setupNameLabel()
        setupMinusButton()
        setupCountLabel()
        setupPlusButton()
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(minusButton)
        contentView.addSubview(countLabel)
        contentView.addSubview(plusButton)
        
        setupConstraints()
        applyStyles()
    }
    
    func setupNameLabel() {
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
    }
    
    func setupMinusButton() {
        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        minusButton.backgroundColor = .white
        minusButton.setTitleColor(.systemBlue, for: .normal)
        minusButton.setTitleColor(.gray, for: .disabled)
        minusButton.clipsToBounds = true
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
    }
    
    func setupCountLabel() {
        countLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        countLabel.textAlignment = .center
        countLabel.textColor = .white
        countLabel.text = "0"
    }
    
    func setupPlusButton() {
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        plusButton.backgroundColor = .white
        plusButton.setTitleColor(.systemBlue, for: .normal)
        plusButton.setTitleColor(.gray, for: .disabled)
        plusButton.clipsToBounds = true
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        [nameLabel, minusButton, countLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Minus Button
            minusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            minusButton.widthAnchor.constraint(equalToConstant: 20),
            minusButton.heightAnchor.constraint(equalToConstant: 20),
            minusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Count Label
            countLabel.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 4),
            countLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -4),
            
            // Plus Button
            plusButton.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            plusButton.widthAnchor.constraint(equalToConstant: 20),
            plusButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        // Можно добавить стилизацию на основе темы
    }
}

final class CircleButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}
