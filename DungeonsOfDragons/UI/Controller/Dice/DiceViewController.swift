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
    private let rollButton = UIButton()
    private let diceRollArea = UIView()
    private let diceRollLabel = UILabel()
    private var diceSceneView: SCNView?
    
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
        setupDiceRollArea()
        setupRollButton()
    }
    
    func setupDiceRollArea() {
        diceRollArea.backgroundColor = UIColor(white: 0.15, alpha: 1.0) // Светло-серый фон
        diceRollArea.translatesAutoresizingMaskIntoConstraints = false
        
        diceRollLabel.text = "Поле броска дайсов"
        diceRollLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        diceRollLabel.textColor = .white
        diceRollLabel.textAlignment = .center
        diceRollLabel.translatesAutoresizingMaskIntoConstraints = false
        
        diceRollArea.addSubview(diceRollLabel)
        view.addSubview(diceRollArea)
        
        NSLayoutConstraint.activate([
            diceRollLabel.centerXAnchor.constraint(equalTo: diceRollArea.centerXAnchor),
            diceRollLabel.centerYAnchor.constraint(equalTo: diceRollArea.centerYAnchor)
        ])
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        let itemWidth: CGFloat = 140
        let itemHeight: CGFloat = 140
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DiceCollectionCell.self, forCellWithReuseIdentifier: DiceCollectionCell.description())
        
        view.addSubview(collectionView)
        view.addSubview(rollButton)
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
    
    func setupRollButton() {
        rollButton.setTitle("Бросить кубики", for: .normal)
        rollButton.setTitleColor(.black, for: .normal)
        rollButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        rollButton.layer.cornerRadius = 12
        rollButton.clipsToBounds = true
        rollButton.translatesAutoresizingMaskIntoConstraints = false
        rollButton.addTarget(self, action: #selector(rollButtonTapped), for: .touchUpInside)
    }
    
    @objc func rollButtonTapped() {
        // Проверяем, выбраны ли дайсы
        guard totalDiceCount > 0 else {
            showNoDiceSelectedAlert()
            return
        }
        
        // Скрываем кнопку и надпись
        UIView.animate(withDuration: 0.3) {
            self.rollButton.alpha = 0
            self.diceRollLabel.alpha = 0
        } completion: { _ in
            self.rollButton.isHidden = true
            self.diceRollLabel.isHidden = true
        }
        
        // Запускаем анимацию броска дайсов
        startDiceRollAnimation()
    }
    
    func showNoDiceSelectedAlert() {
        let alert = UIAlertController(
            title: "Внимание",
            message: "Выберите хотя бы один дайс, максимум шесть",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Хорошо", style: .default))
        
        present(alert, animated: true)
    }
    
    func startDiceRollAnimation() {
        // ────────────────────────────────────────────────────────────────
        // 1. Очистка и подготовка новой сцены
        // ────────────────────────────────────────────────────────────────
        diceSceneView?.removeFromSuperview()
        diceSceneView = nil
        
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.isPlaying = true
        sceneView.allowsCameraControl = false
        diceRollArea.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: diceRollArea.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: diceRollArea.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: diceRollArea.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: diceRollArea.bottomAnchor)
        ])
        
        let scene = SCNScene()
        scene.background.contents = UIColor(white: 0.15, alpha: 1.0)
        sceneView.scene = scene
        
        // ────────────────────────────────────────────────────────────────
        // 2. Настройка физики сцены (гравитация)
        // ────────────────────────────────────────────────────────────────
        scene.physicsWorld.gravity = SCNVector3(0, -12, 0)          // ← можно сделать -9.8 для реализма
        
        // ────────────────────────────────────────────────────────────────
        // 3. Камера — самое важное для видимости граней
        // ────────────────────────────────────────────────────────────────
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 6, z: 18)         // выше и дальше — лучше видно несколько граней
        cameraNode.camera?.fieldOfView = 60
        
        // Направляем камеру чуть вниз, чтобы видеть наклонную поверхность
        cameraNode.look(at: SCNVector3(0, -1, 0))
        
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        // ────────────────────────────────────────────────────────────────
        // 4. Освещение
        // ────────────────────────────────────────────────────────────────
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 5, y: 12, z: 10)
        lightNode.light?.intensity = 1800
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        // ────────────────────────────────────────────────────────────────
        // 5. Наклонная поверхность (замена плоского пола)
        // ────────────────────────────────────────────────────────────────
        let platformWidth: CGFloat = 14
        let platformDepth: CGFloat = 14
        let platformThickness: CGFloat = 0.3

        let platform = SCNBox(width: platformWidth, height: platformThickness, length: platformDepth, chamferRadius: 0)
        let platformNode = SCNNode(geometry: platform)

        // Наклон назад на 20 градусов
        let tiltAngle = Float.pi / 180 * 20
        platformNode.rotation = SCNVector4(1, 0, 0, tiltAngle)

        // Центрируем и немного опускаем
        platformNode.position = SCNVector3(0, -1.2, 0)

        // Материал платформы
        let platformMaterial = SCNMaterial()
        platformMaterial.diffuse.contents = UIColor(white: 0.18, alpha: 1.0)
        platformMaterial.specular.contents = UIColor.gray.withAlphaComponent(0.3)
        platformMaterial.shininess = 0.1

        // Правильное присваивание материала
        platform.materials = [platformMaterial]

        // Физика платформы
        platformNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        platformNode.physicsBody?.friction = 0.9
        platformNode.physicsBody?.restitution = 0.15

        scene.rootNode.addChildNode(platformNode)
        
        // ────────────────────────────────────────────────────────────────
        // 6. Усиленная "коробка" — особенно передняя стена (ближе к камере)
        // ────────────────────────────────────────────────────────────────

        // Размеры видимой области (подбирай под свой экран)
        let boxWidth: Float  = 12.0      // ширина по X
        let boxDepth: Float  = 10.0      // глубина по Z — уменьшили, чтобы передняя стена была ближе
        let boxHeight: Float = 10.0
        let wallThickness: Float = 1.5   // очень толстые стены

        let halfWidth  = boxWidth / 2
        let halfDepth  = boxDepth / 2
        let halfHeight = boxHeight / 2

        // Передняя стена — ближе к камере и толще всех
        let frontWallGeo = SCNBox(width: CGFloat(boxWidth), height: CGFloat(boxHeight), length: CGFloat(wallThickness), chamferRadius: 0)
        let frontWallNode = SCNNode(geometry: frontWallGeo)

        // Ключевой момент: сдвигаем переднюю стену ближе к центру (меньше halfDepth)
        frontWallNode.position = SCNVector3(0, halfHeight - 1.2, halfDepth + wallThickness / 2 - 1.0)  // ← -1.0 — приближаем
        frontWallNode.opacity = 0.0

        let frontBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: frontWallGeo, options: nil))
        frontBody.friction = 1.0
        frontBody.restitution = 0.05     // почти никакого отскока
        frontWallNode.physicsBody = frontBody
        scene.rootNode.addChildNode(frontWallNode)

        // Задняя стена (для симметрии)
        let backWallGeo = SCNBox(width: CGFloat(boxWidth), height: CGFloat(boxHeight), length: CGFloat(wallThickness), chamferRadius: 0)
        let backWallNode = SCNNode(geometry: backWallGeo)
        backWallNode.position = SCNVector3(0, halfHeight - 1.2, -halfDepth - wallThickness / 2 + 1.0)  // тоже приближаем
        backWallNode.opacity = 0.0
        backWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: backWallGeo, options: nil))
        backWallNode.physicsBody?.friction = 1.0
        backWallNode.physicsBody?.restitution = 0.05
        scene.rootNode.addChildNode(backWallNode)

        // Левая и правая стены
        let sideWallGeo = SCNBox(width: CGFloat(wallThickness), height: CGFloat(boxHeight), length: CGFloat(boxDepth), chamferRadius: 0)

        // Левая
        let leftWallNode = SCNNode(geometry: sideWallGeo)
        leftWallNode.position = SCNVector3(-halfWidth - wallThickness/2, halfHeight - 1.2, 0)
        leftWallNode.opacity = 0.0
        leftWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sideWallGeo, options: nil))
        leftWallNode.physicsBody?.friction = 1.0
        leftWallNode.physicsBody?.restitution = 0.05
        scene.rootNode.addChildNode(leftWallNode)

        // Правая
        let rightWallNode = SCNNode(geometry: sideWallGeo)
        rightWallNode.position = SCNVector3(halfWidth + wallThickness/2, halfHeight - 1.2, 0)
        rightWallNode.opacity = 0.0
        rightWallNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sideWallGeo, options: nil))
        rightWallNode.physicsBody?.friction = 1.0
        rightWallNode.physicsBody?.restitution = 0.05
        scene.rootNode.addChildNode(rightWallNode)

        // Потолок (чтобы не улетали вверх)
        let ceilingGeo = SCNBox(width: CGFloat(boxWidth), height: CGFloat(wallThickness), length: CGFloat(boxDepth), chamferRadius: 0)
        let ceilingNode = SCNNode(geometry: ceilingGeo)
        ceilingNode.position = SCNVector3(0, halfHeight + wallThickness/2 - 1.2, 0)
        ceilingNode.opacity = 0.0
        ceilingNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: ceilingGeo, options: nil))
        ceilingNode.physicsBody?.friction = 1.0
        ceilingNode.physicsBody?.restitution = 0.05
        scene.rootNode.addChildNode(ceilingNode)
        
        // ────────────────────────────────────────────────────────────────
        // 7. Создание и бросок дайсов
        // ────────────────────────────────────────────────────────────────
        let diceScale: Float = 0.8
        let spacing: Float = 2.0
        let startHeight: Float = 3.5
        
        var diceNodes: [SCNNode] = []
        var xOffset: Float = -Float(totalDiceCount - 1) * spacing / 2.0
        
        for (diceType, count) in diceCounts where count > 0 {
            for _ in 0..<count {
                let diceGeometry = Dices.createGeometry(for: diceType)
                let diceNode = SCNNode(geometry: diceGeometry)
                
                diceNode.scale = SCNVector3(diceScale, diceScale, diceScale)
                
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.white
                material.specular.contents = UIColor.white
                material.shininess = 0.6
                diceGeometry.materials = [material]
                
                Dices.addNumbersToDice(diceNode: diceNode, diceType: diceType)
                
                diceNode.position = SCNVector3(x: xOffset, y: startHeight, z: 0)
                xOffset += spacing
                
                let physicsShape = SCNPhysicsShape(geometry: diceGeometry, options: nil)
                diceNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
                
                diceNode.physicsBody?.restitution     = 0.4
                diceNode.physicsBody?.friction        = 0.7
                diceNode.physicsBody?.rollingFriction = 0.8
                diceNode.physicsBody?.angularDamping  = 0.6
                diceNode.physicsBody?.damping         = 0.3
                
                let force = SCNVector3(
                    Float.random(in: -1.0...1.0),
                    Float.random(in: 4...6.5),          // меньше вертикального импульса
                    Float.random(in: -1.0...1.0)
                )
                
                let torque = SCNVector4(
                    Float.random(in: -10...10),
                    Float.random(in: -10...10),
                    Float.random(in: -10...10),
                    1
                )
                
                diceNode.physicsBody?.applyForce(force, at: SCNVector3Zero, asImpulse: true)
                diceNode.physicsBody?.applyTorque(torque, asImpulse: true)
                
                scene.rootNode.addChildNode(diceNode)
                diceNodes.append(diceNode)
            }
        }
        
        // ────────────────────────────────────────────────────────────────
        // 8. Финализация — сохраняем сцену и запускаем таймер возврата кнопки
        // ────────────────────────────────────────────────────────────────
        diceSceneView = sceneView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            guard let self = self else { return }
            self.showRollButton()
        }
    }
    
    func showRollButton() {
        // Показываем кнопку после анимации броска (надпись не показываем)
        rollButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.rollButton.alpha = 1
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 172), // 140 + 16*2 (insets)
            
            // Поле броска дайсов - от коллекции до низа экрана
            diceRollArea.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            diceRollArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            diceRollArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            diceRollArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Кнопка поверх поля броска
            rollButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            rollButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rollButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            rollButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        rollButton.backgroundColor = style.accentColor
        rollButton.setTitleColor(.white, for: .normal)
        // Можно добавить стилизацию ячеек здесь
    }
}

// MARK: - UICollectionViewDelegate
extension DiceViewController: UICollectionViewDelegate {
    // Делегат можно использовать для дополнительной логики при необходимости
}


