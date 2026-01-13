//
//  DiceCollectionCell.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit
import SceneKit

final class DiceCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let diceSceneView = SCNView()
    private let nameLabel = UILabel()
    private let minusButton = UIButton(type: .system)
    private let countLabel = UILabel()
    private let plusButton = UIButton(type: .system)
    
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
        
        // Настраиваем 3D дайс, если еще не настроен
        if diceSceneView.scene == nil {
            setupDiceView(diceType: diceType)
        }
    }
    
    private func setupDiceView(diceType: DiceType) {
        // Создаем сцену для дайса
        let scene = SCNScene()
        scene.background.contents = UIColor(white: 0.15, alpha: 1.0) // Светло-серый фон
        diceSceneView.scene = scene
        
        // Создаем геометрию дайса используя статический метод
        let diceGeometry = Dices.createGeometry(for: diceType)
        let diceNode = SCNNode(geometry: diceGeometry)
        
        // Материал для дайса
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.specular.contents = UIColor.white
        material.shininess = 0.5
        diceGeometry.materials = [material]
        
        // Добавляем дайс в сцену
        scene.rootNode.addChildNode(diceNode)
        
        // Добавляем числа на грани
        Dices.addNumbersToDice(diceNode: diceNode, diceType: diceType)
        
        // Настраиваем камеру
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        scene.rootNode.addChildNode(cameraNode)
        
        // Добавляем свет
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Медленная анимация вращения
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 15)
        let repeatRotation = SCNAction.repeatForever(rotation)
        diceNode.runAction(repeatRotation)
    }
    
    func getCurrentCount() -> Int {
        return currentCount
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonCornerRadius()
    }
    
    private func updateButtonCornerRadius() {
        minusButton.layer.cornerRadius = minusButton.bounds.width / 2
        plusButton.layer.cornerRadius = plusButton.bounds.width / 2
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
        contentView.backgroundColor = .black
        
        setupDiceSceneView()
        setupNameLabel()
        setupMinusButton()
        setupCountLabel()
        setupPlusButton()
        
        contentView.addSubview(diceSceneView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(minusButton)
        contentView.addSubview(countLabel)
        contentView.addSubview(plusButton)
        
        setupConstraints()
        applyStyles()
        updateButtonCornerRadius()
    }
    
    func setupDiceSceneView() {
        diceSceneView.translatesAutoresizingMaskIntoConstraints = false
        diceSceneView.backgroundColor = UIColor(white: 0.15, alpha: 1.0) // Светло-серый фон
    }
    
    func setupNameLabel() {
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameLabel.textAlignment = .right
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
        [diceSceneView, nameLabel, minusButton, countLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Name Label - в правом верхнем углу
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            
            // 3D Dice View - в центре верхней части
            diceSceneView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            diceSceneView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            diceSceneView.widthAnchor.constraint(equalToConstant: 100),
            diceSceneView.heightAnchor.constraint(equalToConstant: 100),
            
            // Minus Button - под дайсом с отступом 8
            minusButton.topAnchor.constraint(equalTo: diceSceneView.bottomAnchor, constant: 8),
            minusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            minusButton.widthAnchor.constraint(equalToConstant: 20),
            minusButton.heightAnchor.constraint(equalToConstant: 20),
            
            // Count Label
            countLabel.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            
            // Plus Button
            plusButton.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            plusButton.widthAnchor.constraint(equalToConstant: 20),
            plusButton.heightAnchor.constraint(equalToConstant: 20),
            
            // Bottom constraint to ensure proper height
            minusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        // Можно добавить стилизацию на основе темы
    }
}
