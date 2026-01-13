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
        rollButton.setTitleColor(.white, for: .normal)
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
        // Очищаем предыдущие дайсы
        diceSceneView?.removeFromSuperview()
        diceSceneView = nil
        
        // Создаем сцену для броска дайсов
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor(white: 0.15, alpha: 1.0) // Светло-серый фон
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        diceRollArea.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: diceRollArea.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: diceRollArea.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: diceRollArea.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: diceRollArea.bottomAnchor)
        ])
        
        let scene = SCNScene()
        scene.background.contents = UIColor(white: 0.15, alpha: 1.0) // Светло-серый фон
        sceneView.scene = scene
        
        // Настраиваем камеру
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
        scene.rootNode.addChildNode(cameraNode)
        
        // Добавляем свет
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Создаем дайсы для броска (пока тестируем на d6)
        var diceNodes: [SCNNode] = []
        var xOffset: Float = 0
        
        for (diceType, count) in diceCounts where count > 0 {
            for _ in 0..<count {
                // Пока тестируем только d6
                if diceType.sides == 6 {
                    let diceGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.05)
                    let diceNode = SCNNode(geometry: diceGeometry)
                    
                    // Материал для дайса
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor.white
                    material.specular.contents = UIColor.white
                    material.shininess = 0.5
                    diceGeometry.materials = [material]
                    
                    // Добавляем числа на грани
                    Dices.addNumbersToDice(diceNode: diceNode, diceType: diceType)
                    
                    // Позиционируем дайс
                    diceNode.position = SCNVector3(x: xOffset, y: 3, z: 0)
                    xOffset += 2.5
                    
                    scene.rootNode.addChildNode(diceNode)
                    diceNodes.append(diceNode)
                }
            }
        }
        
        // Анимация броска
        animateDiceRoll(diceNodes: diceNodes) {
            // После завершения анимации показываем кнопку
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showRollButton()
            }
        }
        
        diceSceneView = sceneView
    }
    
    func animateDiceRoll(diceNodes: [SCNNode], completion: @escaping () -> Void) {
        guard !diceNodes.isEmpty else {
            completion()
            return
        }
        
        var completedAnimations = 0
        let totalAnimations = diceNodes.count
        
        for diceNode in diceNodes {
            // Случайное вращение
            let randomRotationX = Float.random(in: 0...(Float.pi * 2))
            let randomRotationY = Float.random(in: 0...(Float.pi * 2))
            let randomRotationZ = Float.random(in: 0...(Float.pi * 2))
            
            // Анимация падения и вращения
            let fallAction = SCNAction.move(to: SCNVector3(diceNode.position.x, -1, diceNode.position.z), duration: 1.5)
            let rotateAction = SCNAction.rotateBy(x: CGFloat(randomRotationX * 5), y: CGFloat(randomRotationY * 5), z: CGFloat(randomRotationZ * 5), duration: 1.5)
            
            let groupAction = SCNAction.group([fallAction, rotateAction])
            groupAction.timingMode = .easeOut
            
            diceNode.runAction(groupAction) {
                completedAnimations += 1
                if completedAnimations == totalAnimations {
                    completion()
                }
            }
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

// MARK: - Dices View
final class Dices: UIView {
    private let diceTypes: [DiceType]
    private var sceneViews: [SCNView] = []
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    init(diceTypes: [DiceType]) {
        self.diceTypes = diceTypes
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Статический метод для создания одного дайса (для использования в ячейках)
    static func createSingleDiceView(for diceType: DiceType, size: CGFloat = 60) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false // Отключаем управление камерой в ячейке
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X
        
        let scene = SCNScene()
        scene.background.contents = UIColor(white: 0.15, alpha: 1.0) // Светло-серый фон
        sceneView.scene = scene
        
        // Создаем геометрию дайса
        let diceGeometry = createGeometry(for: diceType)
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
        addNumbersToDice(diceNode: diceNode, diceType: diceType)
        
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
        
        // Размеры view
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = UIColor(white: 0.15, alpha: 1.0) // Светло-серый фон
        NSLayoutConstraint.activate([
            sceneView.widthAnchor.constraint(equalToConstant: size),
            sceneView.heightAnchor.constraint(equalToConstant: size)
        ])
        
        // Медленная анимация вращения
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 15)
        let repeatRotation = SCNAction.repeatForever(rotation)
        diceNode.runAction(repeatRotation)
        
        return sceneView
    }
    
    static func createGeometry(for diceType: DiceType) -> SCNGeometry {
        switch diceType.sides {
        case 4:
            return Self.createTetrahedron()
        case 6:
            return SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.05)
        case 8:
            return Self.createOctahedron()
        case 10:
            return Self.createPentagonalTrapezohedron()
        case 12:
            return Self.createDodecahedron()
        case 20:
            return Self.createIcosahedron()
        case 100:
            // d100 обычно представлен как сфера с числами 00-90
            let sphere = SCNSphere(radius: 0.7)
            sphere.segmentCount = 20 // Увеличиваем сегменты для более гладкой формы
            return sphere
        default:
            return SCNSphere(radius: 0.5)
        }
    }
    
    static func addNumbersToDice(diceNode: SCNNode, diceType: DiceType) {
        switch diceType.sides {
        case 4:
            Self.addNumbersToTetrahedron(diceNode: diceNode)
        case 6:
            Self.addNumbersToCube(diceNode: diceNode)
        case 8:
            Self.addNumbersToOctahedron(diceNode: diceNode)
        case 10:
            Self.addNumbersToD10(diceNode: diceNode)
        case 12:
            Self.addNumbersToD12(diceNode: diceNode)
        case 20:
            Self.addNumbersToD20(diceNode: diceNode)
        case 100:
            Self.addNumbersToD100(diceNode: diceNode)
        default:
            break
        }
    }
    
    private func setupView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -32)
        ])
        
        createDiceViews()
    }
    
    private func createDiceViews() {
        for diceType in diceTypes {
            let sceneView = createDiceSceneView(for: diceType)
            sceneViews.append(sceneView)
            stackView.addArrangedSubview(sceneView)
        }
    }
    
    private func createDiceSceneView(for diceType: DiceType) -> SCNView {
        return Self.createSingleDiceView(for: diceType, size: 100)
    }
    
    private static func createTextNode(text: String, position: SCNVector3, normal: SCNVector3) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.01)
        textGeometry.font = UIFont.systemFont(ofSize: 0.2, weight: .bold)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black
        textGeometry.firstMaterial?.specular.contents = UIColor.white
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.flatness = 0.1
        
        let textNode = SCNNode(geometry: textGeometry)
        
        // Центрируем текст
        let (min, max) = textGeometry.boundingBox
        let width = max.x - min.x
        let height = max.y - min.y
        let depth = max.z - min.z
        
        textNode.pivot = SCNMatrix4MakeTranslation(
            min.x + width / 2,
            min.y + height / 2,
            min.z + depth / 2
        )
        
        // Позиционируем на грани (немного выше поверхности)
        textNode.position = SCNVector3(
            position.x + normal.x * 0.52,
            position.y + normal.y * 0.52,
            position.z + normal.z * 0.52
        )
        
        // Вычисляем углы поворота для ориентации текста перпендикулярно грани
        // Текст должен смотреть в направлении нормали
        let normalized = Self.normalize(normal)
        
        // Вычисляем углы Эйлера
        let pitch = asin(-normalized.y)
        let yaw = atan2(normalized.x, normalized.z)
        
        textNode.eulerAngles = SCNVector3(pitch, yaw, 0)
        
        return textNode
    }
    
    private static func dotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        return a.x * b.x + a.y * b.y + a.z * b.z
    }
    
    private static func crossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        )
    }
    
    private static func length(_ v: SCNVector3) -> Float {
        return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    }
    
    private static func addNumbersToCube(diceNode: SCNNode) {
        let size: Float = 0.5
        let offset: Float = 0.51
        
        // Грани куба: передняя, задняя, правая, левая, верхняя, нижняя
        let faces: [(position: SCNVector3, normal: SCNVector3, number: Int)] = [
            (SCNVector3(0, 0, size), SCNVector3(0, 0, 1), 1),      // Передняя
            (SCNVector3(0, 0, -size), SCNVector3(0, 0, -1), 2),    // Задняя
            (SCNVector3(size, 0, 0), SCNVector3(1, 0, 0), 3),      // Правая
            (SCNVector3(-size, 0, 0), SCNVector3(-1, 0, 0), 4),     // Левая
            (SCNVector3(0, size, 0), SCNVector3(0, 1, 0), 5),      // Верхняя
            (SCNVector3(0, -size, 0), SCNVector3(0, -1, 0), 6)     // Нижняя
        ]
        
        for face in faces {
            let textNode = Self.createTextNode(
                text: "\(face.number)",
                position: face.position,
                normal: face.normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToTetrahedron(diceNode: SCNNode) {
        // Тетраэдр: 4 грани, числа 1-4
        let faces: [(position: SCNVector3, normal: SCNVector3, number: Int)] = [
            (SCNVector3(0, 0.27, 0), SCNVector3(0, 0.577, 0.577), 1),
            (SCNVector3(-0.24, -0.14, 0.14), SCNVector3(-0.577, -0.577, 0.577), 2),
            (SCNVector3(0.24, -0.14, 0.14), SCNVector3(0.577, -0.577, 0.577), 3),
            (SCNVector3(0, -0.14, -0.27), SCNVector3(0, -0.577, -0.577), 4)
        ]
        
        for face in faces {
            let textNode = Self.createTextNode(
                text: "\(face.number)",
                position: face.position,
                normal: face.normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToOctahedron(diceNode: SCNNode) {
        // Октаэдр: 8 граней, числа 1-8
        // Центры граней октаэдра находятся на средних точках между вершинами
        let sqrt2: Float = 0.707
        let faces: [(position: SCNVector3, normal: SCNVector3, number: Int)] = [
            // Верхние 4 грани
            (SCNVector3(0.33, 0.33, 0), Self.normalize(SCNVector3(0, sqrt2, sqrt2)), 1),
            (SCNVector3(0.33, 0, 0.33), Self.normalize(SCNVector3(sqrt2, 0, sqrt2)), 2),
            (SCNVector3(-0.33, 0, 0.33), Self.normalize(SCNVector3(-sqrt2, 0, sqrt2)), 3),
            (SCNVector3(-0.33, 0.33, 0), Self.normalize(SCNVector3(0, sqrt2, -sqrt2)), 4),
            // Нижние 4 грани
            (SCNVector3(0.33, -0.33, 0), Self.normalize(SCNVector3(0, -sqrt2, sqrt2)), 5),
            (SCNVector3(0.33, 0, -0.33), Self.normalize(SCNVector3(sqrt2, 0, -sqrt2)), 6),
            (SCNVector3(-0.33, 0, -0.33), Self.normalize(SCNVector3(-sqrt2, 0, -sqrt2)), 7),
            (SCNVector3(-0.33, -0.33, 0), Self.normalize(SCNVector3(0, -sqrt2, -sqrt2)), 8)
        ]
        
        for face in faces {
            let textNode = Self.createTextNode(
                text: "\(face.number)",
                position: face.position,
                normal: face.normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToD10(diceNode: SCNNode) {
        // d10: 10 граней, числа 1-10
        // Распределяем числа равномерно по поверхности сферы
        let goldenAngle = Float.pi * (3.0 - sqrt(5.0))
        
        for i in 1...10 {
            let y = 1.0 - (Float(i) / Float(10)) * 2.0
            let radius = sqrt(1.0 - y * y)
            let theta = goldenAngle * Float(i)
            
            let x = cos(theta) * radius
            let z = sin(theta) * radius
            
            let position = SCNVector3(x * 0.55, y * 0.55, z * 0.55)
            let normal = Self.normalize(SCNVector3(x, y, z))
            
            let textNode = Self.createTextNode(
                text: "\(i)",
                position: position,
                normal: normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToD12(diceNode: SCNNode) {
        // d12: 12 граней, числа 1-12
        // Распределяем числа равномерно по поверхности сферы
        let goldenAngle = Float.pi * (3.0 - sqrt(5.0))
        
        for i in 1...12 {
            let y = 1.0 - (Float(i) / Float(12)) * 2.0
            let radius = sqrt(1.0 - y * y)
            let theta = goldenAngle * Float(i)
            
            let x = cos(theta) * radius
            let z = sin(theta) * radius
            
            let position = SCNVector3(x * 0.6, y * 0.6, z * 0.6)
            let normal = Self.normalize(SCNVector3(x, y, z))
            
            let textNode = Self.createTextNode(
                text: "\(i)",
                position: position,
                normal: normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToD20(diceNode: SCNNode) {
        // d20: 20 граней, числа 1-20
        // Используем равномерное распределение по сфере для центров граней
        // Алгоритм Фибоначчи для равномерного распределения точек на сфере
        let goldenAngle = Float.pi * (3.0 - sqrt(5.0)) // Золотой угол
        
        for i in 1...20 {
            let y = 1.0 - (Float(i) / Float(20)) * 2.0 // От -1 до 1
            let radius = sqrt(1.0 - y * y)
            let theta = goldenAngle * Float(i)
            
            let x = cos(theta) * radius
            let z = sin(theta) * radius
            
            let position = SCNVector3(x * 0.65, y * 0.65, z * 0.65)
            let normal = Self.normalize(SCNVector3(x, y, z))
            
            let textNode = Self.createTextNode(
                text: "\(i)",
                position: position,
                normal: normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToD100(diceNode: SCNNode) {
        // d100: обычно числа 00, 10, 20, ..., 90
        // Распределяем числа равномерно по поверхности сферы
        let goldenAngle = Float.pi * (3.0 - sqrt(5.0))
        
        for i in 0...9 {
            let y = 1.0 - (Float(i + 1) / Float(10)) * 2.0
            let radius = sqrt(1.0 - y * y)
            let theta = goldenAngle * Float(i + 1)
            
            let x = cos(theta) * radius
            let z = sin(theta) * radius
            
            let position = SCNVector3(x * 0.55, y * 0.55, z * 0.55)
            let normal = Self.normalize(SCNVector3(x, y, z))
            
            let number = i * 10
            let textNode = Self.createTextNode(
                text: number == 0 ? "00" : "\(number)",
                position: position,
                normal: normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func normalize(_ v: SCNVector3) -> SCNVector3 {
        let len = length(v)
        guard len > 0 else { return v }
        return SCNVector3(v.x / len, v.y / len, v.z / len)
    }
    
    private func createGeometry(for diceType: DiceType) -> SCNGeometry {
        return Self.createGeometry(for: diceType)
    }
    
    private static func createTetrahedron() -> SCNGeometry {
        let vertices: [SCNVector3] = [
            SCNVector3(0, 0.816, 0),
            SCNVector3(-0.707, -0.408, 0.408),
            SCNVector3(0.707, -0.408, 0.408),
            SCNVector3(0, -0.408, -0.816)
        ]
        
        let indices: [Int32] = [
            0, 1, 2,
            0, 2, 3,
            0, 3, 1,
            1, 3, 2
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: 4, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createOctahedron() -> SCNGeometry {
        let vertices: [SCNVector3] = [
            SCNVector3(0, 1, 0),      // Верх
            SCNVector3(1, 0, 0),      // Перед-право
            SCNVector3(0, 0, 1),      // Перед-лево
            SCNVector3(-1, 0, 0),     // Зад-лево
            SCNVector3(0, 0, -1),     // Зад-право
            SCNVector3(0, -1, 0)      // Низ
        ]
        
        let indices: [Int32] = [
            0, 1, 2,   // Верхняя грань 1
            0, 2, 3,   // Верхняя грань 2
            0, 3, 4,   // Верхняя грань 3
            0, 4, 1,   // Верхняя грань 4
            5, 2, 1,   // Нижняя грань 1
            5, 3, 2,   // Нижняя грань 2
            5, 4, 3,   // Нижняя грань 3
            5, 1, 4    // Нижняя грань 4
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: 8, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createPentagonalTrapezohedron() -> SCNGeometry {
        // d10 - Пентагональная трапецоэдра (10 граней)
        // Правильная форма: два пентагона, повернутые на 36°, соединенные ромбовидными гранями
        let phi = (1.0 + sqrt(5.0)) / 2.0
        let h: Float = 0.6 // Высота от центра до полюса
        let r: Float = 0.5 // Радиус пентагонов
        let z: Float = 0.2 // Высота пентагонов от центра
        
        var vertices: [SCNVector3] = []
        
        // Верхний полюс (индекс 0)
        vertices.append(SCNVector3(0, h, 0))
        
        // Верхний пентагон (индексы 1-5)
        for i in 0..<5 {
            let angle = Float(i) * 2.0 * Float.pi / 5.0
            let x = r * cos(angle)
            let zCoord = r * sin(angle)
            vertices.append(SCNVector3(x, z, zCoord))
        }
        
        // Нижний пентагон, повернут на 36° (индексы 6-10)
        for i in 0..<5 {
            let angle = Float(i) * 2.0 * Float.pi / 5.0 + Float.pi / 5.0
            let x = r * cos(angle)
            let zCoord = r * sin(angle)
            vertices.append(SCNVector3(x, -z, zCoord))
        }
        
        // Нижний полюс (индекс 11)
        vertices.append(SCNVector3(0, -h, 0))
        
        // Индексы для 10 граней (каждая грань - ромб из 2 треугольников)
        var indices: [Int32] = []
        
        // Верхние 5 граней (от верхнего полюса к верхнему пентагону)
        for i in 0..<5 {
            let next = (i + 1) % 5
            indices.append(contentsOf: [0, Int32(1 + i), Int32(1 + next)])
        }
        
        // Средние 10 граней (ромбы, соединяющие верхний и нижний пентагоны)
        for i in 0..<5 {
            let next = (i + 1) % 5
            let upper = Int32(1 + i)
            let upperNext = Int32(1 + next)
            let lower = Int32(6 + i)
            let lowerNext = Int32(6 + next)
            
            // Два треугольника для ромба
            indices.append(contentsOf: [upper, lower, upperNext])
            indices.append(contentsOf: [upperNext, lower, lowerNext])
        }
        
        // Нижние 5 граней (от нижнего пентагона к нижнему полюсу)
        for i in 0..<5 {
            let next = (i + 1) % 5
            indices.append(contentsOf: [11, Int32(6 + next), Int32(6 + i)])
        }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createDodecahedron() -> SCNGeometry {
        // Додекаэдр - правильный 12-гранник (каждая грань - правильный пятиугольник)
        let phi = (1.0 + sqrt(5.0)) / 2.0
        let a: Float = Float(1.0 / phi)
        let b: Float = 1.0
        let radius: Float = 0.7
        
        // 20 вершин додекаэдра (правильные координаты)
        let vertices: [SCNVector3] = [
            SCNVector3(0, b, a), SCNVector3(0, b, -a), SCNVector3(0, -b, a), SCNVector3(0, -b, -a),
            SCNVector3(a, 0, b), SCNVector3(-a, 0, b), SCNVector3(a, 0, -b), SCNVector3(-a, 0, -b),
            SCNVector3(b, a, 0), SCNVector3(-b, a, 0), SCNVector3(b, -a, 0), SCNVector3(-b, -a, 0),
            SCNVector3(1, 1, 1), SCNVector3(1, 1, -1), SCNVector3(1, -1, 1), SCNVector3(1, -1, -1),
            SCNVector3(-1, 1, 1), SCNVector3(-1, 1, -1), SCNVector3(-1, -1, 1), SCNVector3(-1, -1, -1)
        ]
        
        // Нормализуем и масштабируем
        let normalizedVertices = vertices.map { v -> SCNVector3 in
            let length = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
            return SCNVector3(v.x / length * radius, v.y / length * radius, v.z / length * radius)
        }
        
        // Индексы для 12 пятиугольных граней (каждая грань разбита на 3 треугольника)
        // Грани додекаэдра (правильная структура)
        let indices: [Int32] = [
            // Грань 1: вершины 0, 12, 4, 16, 5
            0, 12, 4, 0, 4, 16, 0, 16, 5,
            // Грань 2: вершины 0, 5, 9, 17, 12
            0, 5, 9, 0, 9, 17, 0, 17, 12,
            // Грань 3: вершины 1, 13, 6, 8, 12
            1, 13, 6, 1, 6, 8, 1, 8, 12,
            // Грань 4: вершины 1, 12, 5, 17, 13
            1, 12, 5, 1, 5, 17, 1, 17, 13,
            // Грань 5: вершины 2, 14, 10, 8, 13
            2, 14, 10, 2, 10, 8, 2, 8, 13,
            // Грань 6: вершины 2, 13, 7, 18, 14
            2, 13, 7, 2, 7, 18, 2, 18, 14,
            // Грань 7: вершины 3, 15, 11, 9, 17
            3, 15, 11, 3, 11, 9, 3, 9, 17,
            // Грань 8: вершины 3, 17, 4, 19, 15
            3, 17, 4, 3, 4, 19, 3, 19, 15,
            // Грань 9: вершины 4, 12, 8, 10, 14
            4, 12, 8, 4, 8, 10, 4, 10, 14,
            // Грань 10: вершины 4, 14, 19, 16, 12
            4, 14, 19, 4, 19, 16, 4, 16, 12,
            // Грань 11: вершины 6, 13, 2, 18, 15
            6, 13, 2, 6, 2, 18, 6, 18, 15,
            // Грань 12: вершины 6, 15, 7, 8, 13
            6, 15, 7, 6, 7, 8, 6, 8, 13,
            // Грань 13: вершины 7, 15, 3, 19, 14
            7, 15, 3, 7, 3, 19, 7, 19, 14,
            // Грань 14: вершины 7, 14, 2, 18, 15
            7, 14, 2, 7, 2, 18, 7, 18, 15,
            // Грань 15: вершины 9, 17, 1, 13, 5
            9, 17, 1, 9, 1, 13, 9, 13, 5,
            // Грань 16: вершины 9, 5, 0, 12, 17
            9, 5, 0, 9, 0, 12, 9, 12, 17,
            // Грань 17: вершины 10, 8, 6, 15, 11
            10, 8, 6, 10, 6, 15, 10, 15, 11,
            // Грань 18: вершины 10, 11, 9, 17, 8
            10, 11, 9, 10, 9, 17, 10, 17, 8,
            // Грань 19: вершины 11, 15, 6, 8, 9
            11, 15, 6, 11, 6, 8, 11, 8, 9,
            // Грань 20: вершины 16, 4, 14, 19, 3
            16, 4, 14, 16, 14, 19, 16, 19, 3
        ]
        
        let vertexSource = SCNGeometrySource(vertices: normalizedVertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createIcosahedron() -> SCNGeometry {
        // Икосаэдр - 20-гранная фигура
        let t = (1.0 + sqrt(5.0)) / 2.0 // Золотое сечение
        
        let vertices: [SCNVector3] = [
            SCNVector3(-1, t, 0), SCNVector3(1, t, 0), SCNVector3(-1, -t, 0), SCNVector3(1, -t, 0),
            SCNVector3(0, -1, t), SCNVector3(0, 1, t), SCNVector3(0, -1, -t), SCNVector3(0, 1, -t),
            SCNVector3(t, 0, -1), SCNVector3(t, 0, 1), SCNVector3(-t, 0, -1), SCNVector3(-t, 0, 1)
        ]
        
        // Нормализуем вершины
        let normalizedVertices = vertices.map { v -> SCNVector3 in
            let length = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
            return SCNVector3(v.x / length, v.y / length, v.z / length)
        }
        
        let indices: [Int32] = [
            0, 11, 5,   0, 5, 1,    0, 1, 7,    0, 7, 10,   0, 10, 11,
            1, 5, 9,    5, 11, 4,   11, 10, 2,  10, 7, 6,   7, 1, 8,
            3, 9, 4,    3, 4, 2,    3, 2, 6,    3, 6, 8,    3, 8, 9,
            4, 9, 5,    2, 4, 11,    6, 2, 10,   8, 6, 7,    9, 8, 1
        ]
        
        let vertexSource = SCNGeometrySource(vertices: normalizedVertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: 20, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
}
