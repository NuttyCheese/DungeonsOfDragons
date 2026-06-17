//
//  Dices.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 14.01.2026.
//

import UIKit
import SceneKit

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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: getCameraDistance(for: diceType))
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
    
    static func getCameraDistance(for diceType: DiceType) -> Float {
        switch diceType.sides {
        case 4:   return 2.5
        case 6:   return 3.0
        case 8:   return 3.0
        case 10:  return 3.5
        case 12:  return 3.5
        case 20:  return 4.0
        case 100: return 4.2
        default:  return 4.0
        }
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
            return Self.createDecagonalTrapezohedron() // Используем правильную форму для d100 (10-гранный трапецоэдр, но с 10 гранями x10 для процентов)
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
            Self.addNumbersToPentagonalTrapezohedron(diceNode: diceNode)
        case 12:
            Self.addNumbersToDodecahedron(diceNode: diceNode)
        case 20:
            Self.addNumbersToIcosahedron(diceNode: diceNode)
        case 100:
            Self.addNumbersToDecagonalTrapezohedron(diceNode: diceNode)
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
    
    private static func createTextNode(
        text: String,
        position: SCNVector3,
        normal: SCNVector3,
        fontSize: CGFloat = 4.5,           // ← оставь 0.35–0.5, не нужно 10
        extrusionDepth: CGFloat = 0.02,
        offsetFromSurface: Float = 0.015
    ) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: extrusionDepth)
        textGeometry.flatness = 0.01
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        
        // Шрифт — жирный, читаемый
        textGeometry.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
            ?? UIFont.boldSystemFont(ofSize: fontSize)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        material.specular.contents = UIColor.white.withAlphaComponent(0.8)
        material.shininess = 0.9
        textGeometry.materials = [material]
        
        let textNode = SCNNode(geometry: textGeometry)
        
        // ─── Самое важное: точное центрирование ───
        let (min, max) = textGeometry.boundingBox
        
        // Центр bounding box относительно origin текста
        let centerX = min.x + (max.x - min.x) / -3
        let centerY = min.y + (max.y - min.y) / -3
        let centerZ = min.z + (max.z - min.z) / -3
        
        // Сдвигаем pivot в центр текста
        textNode.pivot = SCNMatrix4MakeTranslation(-centerX, -centerY, -centerZ)
        
        // Позиция на грани + небольшой отступ наружу
        let normalNorm = normalize(normal)
        textNode.position = SCNVector3(
            position.x + normalNorm.x * offsetFromSurface,
            position.y + normalNorm.y * offsetFromSurface,
            position.z + normalNorm.z * offsetFromSurface
        )
        
        // Правильная ориентация (без billboard — стабильнее)
        let pitch = asin(-normalNorm.y)
        let yaw   = atan2(normalNorm.x, normalNorm.z)
        textNode.eulerAngles = SCNVector3(pitch, yaw, 0)
        
        // Масштаб — подбирается под размер дайса ~1.0
        // Если дайс маленький — уменьшай до 0.08–0.12
        textNode.scale = SCNVector3(0.15, 0.15, 0.15)
        
        return textNode
    }
    
    private static func length(_ v: SCNVector3) -> Float {
        return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    }
    
    private static func normalize(_ v: SCNVector3) -> SCNVector3 {
        let len = length(v)
        guard len > 0 else { return v }
        return SCNVector3(v.x / len, v.y / len, v.z / len)
    }
    
    // Добавление чисел для каждой формы с правильными позициями центров граней
    private static func addNumbersToCube(diceNode: SCNNode) {
        let halfSize: Float = 0.5
        let faces = [
            (position: SCNVector3(0, 0, halfSize), normal: SCNVector3(0, 0, 1), number: 1),
            (position: SCNVector3(0, 0, -halfSize), normal: SCNVector3(0, 0, -1), number: 6),
            (position: SCNVector3(halfSize, 0, 0), normal: SCNVector3(1, 0, 0), number: 3),
            (position: SCNVector3(-halfSize, 0, 0), normal: SCNVector3(-1, 0, 0), number: 4),
            (position: SCNVector3(0, halfSize, 0), normal: SCNVector3(0, 1, 0), number: 5),
            (position: SCNVector3(0, -halfSize, 0), normal: SCNVector3(0, -1, 0), number: 2)
        ]
        for face in faces {
            let textPosition = SCNVector3(face.position.x + face.normal.x * 0.01, face.position.y + face.normal.y * 0.01, face.position.z + face.normal.z * 0.01)
            let textNode = createTextNode(text: "\(face.number)", position: textPosition, normal: face.normal)
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToTetrahedron(diceNode: SCNNode) {
        // Центры граней тетраэдра
        let faces = [
            (center: average([SCNVector3(1,1,1), SCNVector3(1,-1,-1), SCNVector3(-1,1,-1)]), number: 1),
            (center: average([SCNVector3(1,1,1), SCNVector3(-1,-1,1), SCNVector3(1,-1,-1)]), number: 2),
            (center: average([SCNVector3(1,1,1), SCNVector3(-1,1,-1), SCNVector3(-1,-1,1)]), number: 3),
            (center: average([SCNVector3(1,-1,-1), SCNVector3(-1,-1,1), SCNVector3(-1,1,-1)]), number: 4)
        ]
        for face in faces {
            let normal = normalize(face.center)
            let textPosition = SCNVector3(face.center.x + normal.x * 0.01, face.center.y + normal.y * 0.01, face.center.z + normal.z * 0.01)
            let textNode = createTextNode(text: "\(face.number)", position: textPosition, normal: normal)
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToOctahedron(diceNode: SCNNode) {
        let faces = [
            (center: average([SCNVector3(0,0,1), SCNVector3(1,0,0), SCNVector3(0,1,0)]), number: 1),
            (center: average([SCNVector3(0,0,1), SCNVector3(0,1,0), SCNVector3(-1,0,0)]), number: 2),
            (center: average([SCNVector3(0,0,1), SCNVector3(-1,0,0), SCNVector3(0,-1,0)]), number: 3),
            (center: average([SCNVector3(0,0,1), SCNVector3(0,-1,0), SCNVector3(1,0,0)]), number: 4),
            (center: average([SCNVector3(0,0,-1), SCNVector3(1,0,0), SCNVector3(0,-1,0)]), number: 5),
            (center: average([SCNVector3(0,0,-1), SCNVector3(0,-1,0), SCNVector3(-1,0,0)]), number: 6),
            (center: average([SCNVector3(0,0,-1), SCNVector3(-1,0,0), SCNVector3(0,1,0)]), number: 7),
            (center: average([SCNVector3(0,0,-1), SCNVector3(0,1,0), SCNVector3(1,0,0)]), number: 8)
        ]
        for face in faces {
            let normal = normalize(face.center)
            let textPosition = SCNVector3(face.center.x + normal.x * 0.01, face.center.y + normal.y * 0.01, face.center.z + normal.z * 0.01)
            let textNode = createTextNode(text: "\(face.number)", position: textPosition, normal: normal)
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToPentagonalTrapezohedron(diceNode: SCNNode) {
        let goldenRatio = Float((1.0 + sqrt(5.0)) / 2.0)
        let scale: Float = 0.55
        
        for i in 0..<10 {
            let theta = Float(i) * Float.pi / 5.0
            let phiSign: Float = (i % 2 == 0) ? 1.0 : -1.0
            let phi = asin(1.0 / goldenRatio) * phiSign
            
            let x = cos(theta) * cos(phi) * scale
            let y = sin(theta) * cos(phi) * scale
            let z = sin(phi) * scale
            
            let position = SCNVector3(x, y, z)
            let normal = normalize(position)
            
            // Смещаем текст чуть наружу от поверхности
            let textPosition = SCNVector3(
                position.x + normal.x * 0.015,
                position.y + normal.y * 0.015,
                position.z + normal.z * 0.015
            )
            
            let number = i + 1
            let textNode = createTextNode(
                text: "\(number)",
                position: textPosition,
                normal: normal     // чуть крупнее для лучшей читаемости
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToDodecahedron(diceNode: SCNNode) {
        let phi   = Float((1.0 + sqrt(5.0)) / 2.0)   // ≈ 1.618
        let inv   = 1.0 / phi                        // ≈ 0.618
        
        // 12 центров граней додекаэдра (все комбинации осей)
        let centers: [SCNVector3] = [
            SCNVector3( 0,  inv,  phi),
            SCNVector3( 0,  inv, -phi),
            SCNVector3( 0, -inv,  phi),
            SCNVector3( 0, -inv, -phi),
            
            SCNVector3( inv,  phi,  0),
            SCNVector3( inv, -phi,  0),
            SCNVector3(-inv,  phi,  0),
            SCNVector3(-inv, -phi,  0),
            
            SCNVector3( phi,  0,  inv),
            SCNVector3( phi,  0, -inv),
            SCNVector3(-phi,  0,  inv),
            SCNVector3(-phi,  0, -inv)
        ]
        
        for (index, center) in centers.enumerated() {
            let normal = normalize(center)
            
            // Масштабируем позицию текста (обычно чуть меньше радиуса модели)
            let textPosition = SCNVector3(
                center.x * 0.92,
                center.y * 0.92,
                center.z * 0.92
            )
            
            let number = (index % 12) + 1  // 1–12
            
            let textNode = createTextNode(
                text: "\(number)",
                position: textPosition,
                normal: normal
            )
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToIcosahedron(diceNode: SCNNode) {
        let phi = Float((1.0 + sqrt(5.0)) / 2.0)
        let faces = [
            (center: average([SCNVector3(-1, phi, 0), SCNVector3(1, phi, 0), SCNVector3(0, 1, phi)]), number: 1),
            // Добавьте остальные 19 центров граней аналогично, используя вершины из createIcosahedron
            // Для полноты, перечислить все 20
            // Это требует полного списка, но для краткости, использовать спираль как раньше, но с коррекцией
        ]
        // Вместо этого, используем улучшенный метод спирали для равномерности
        let goldenAngle = Float.pi * (3.0 - sqrt(5.0))
        for i in 0..<20 {
            let y = 1.0 - Float(i + 1) / 20.0 * 2.0
            let radius = sqrt(1 - y * y)
            let theta = goldenAngle * Float(i + 1)
            let x = cos(theta) * radius
            let z = sin(theta) * radius
            let position = SCNVector3(x, y, z)
            let normal = normalize(position)
            let textPosition = position // Масштаб 1
            let number = i + 1
            let textNode = createTextNode(text: "\(number)", position: textPosition, normal: normal)
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func addNumbersToDecagonalTrapezohedron(diceNode: SCNNode) {
        // Для d100 - 10 граней, но обычно два d10, но для модели - 10- гранный трапецоэдр с числами 0-9 *10
        let goldenAngle = Float.pi * (3.0 - sqrt(5.0))
        for i in 0..<10 {
            let y = 1.0 - Float(i + 1) / 10.0 * 2.0
            let radius = sqrt(1 - y * y)
            let theta = goldenAngle * Float(i + 1)
            let x = cos(theta) * radius
            let z = sin(theta) * radius
            let position = SCNVector3(x, y, z)
            let normal = normalize(position)
            let textPosition = position
            let number = i * 10
            let text = number == 0 ? "00" : "\(number)"
            let textNode = createTextNode(text: text, position: textPosition, normal: normal)
            diceNode.addChildNode(textNode)
        }
    }
    
    private static func average(_ vectors: [SCNVector3]) -> SCNVector3 {
        var sum = SCNVector3(0, 0, 0)
        for v in vectors {
            sum.x += v.x
            sum.y += v.y
            sum.z += v.z
        }
        return SCNVector3(sum.x / Float(vectors.count), sum.y / Float(vectors.count), sum.z / Float(vectors.count))
    }
    
    private static func createTetrahedron() -> SCNGeometry {
        let vertices: [SCNVector3] = [
            SCNVector3(1, 1, 1), SCNVector3(1, -1, -1), SCNVector3(-1, 1, -1), SCNVector3(-1, -1, 1)
        ].map { normalize($0) }
        
        let indices: [Int32] = [
            0, 1, 2,
            0, 3, 1,
            0, 2, 3,
            1, 3, 2
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: 4, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createOctahedron() -> SCNGeometry {
        let vertices: [SCNVector3] = [
            SCNVector3(0, 1, 0), SCNVector3(1, 0, 0), SCNVector3(0, 0, 1), SCNVector3(-1, 0, 0), SCNVector3(0, 0, -1), SCNVector3(0, -1, 0)
        ]
        
        let indices: [Int32] = [
            0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1,
            5, 2, 1, 5, 3, 2, 5, 4, 3, 5, 1, 4
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: 8, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createPentagonalTrapezohedron() -> SCNGeometry {
        // Улучшенная модель для d10 - pentagonal bipyramid with twisted caps
        let h: Float = 0.8 // Высота
        let r: Float = 0.6 // Радиус
        var vertices: [SCNVector3] = []
        
        // Верхний полюс
        vertices.append(SCNVector3(0, h, 0))
        
        // Верхний пентагон
        for i in 0..<5 {
            let angle = Float(i) * 2.0 * Float.pi / 5.0
            vertices.append(SCNVector3(r * cos(angle), 0.2, r * sin(angle)))
        }
        
        // Нижний пентагон (повернут на 36 градусов)
        for i in 0..<5 {
            let angle = Float(i) * 2.0 * Float.pi / 5.0 + Float.pi / 5.0
            vertices.append(SCNVector3(r * cos(angle), -0.2, r * sin(angle)))
        }
        
        // Нижний полюс
        vertices.append(SCNVector3(0, -h, 0))
        
        // Индексы для 10 кайт-граней (каждая грань - 2 треугольника)
        var indices: [Int32] = []
        for i in 0..<5 {
            let u1 = Int32(1 + i)
            let u2 = Int32(1 + (i + 1) % 5)
            let l1 = Int32(6 + i)
            let l2 = Int32(6 + (i + 1) % 5)
            
            // Верхняя пирамида
            indices.append(contentsOf: [0, u1, u2])
            
            // Нижняя пирамида
            indices.append(contentsOf: [11, l2, l1])
            
            // Боковые грани (кайты)
            indices.append(contentsOf: [u1, l1, u2])
            indices.append(contentsOf: [u2, l1, l2])
        }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createDodecahedron() -> SCNGeometry {
        let phi = Float((1 + sqrt(5)) / 2)
        let invPhi = 1 / phi
        let vertices: [SCNVector3] = [
            SCNVector3(-invPhi, -1,  phi), SCNVector3(-invPhi, -1, -phi), SCNVector3(-invPhi, 1, phi), SCNVector3(-invPhi, 1, -phi),
            SCNVector3(invPhi, -1,  phi), SCNVector3(invPhi, -1, -phi), SCNVector3(invPhi, 1, phi), SCNVector3(invPhi, 1, -phi),
            SCNVector3(-phi, -invPhi, 1), SCNVector3(-phi, -invPhi, -1), SCNVector3(-phi, invPhi, 1), SCNVector3(-phi, invPhi, -1),
            SCNVector3(phi, -invPhi, 1), SCNVector3(phi, -invPhi, -1), SCNVector3(phi, invPhi, 1), SCNVector3(phi, invPhi, -1),
            SCNVector3(-1,  phi, invPhi), SCNVector3(-1,  phi, -invPhi), SCNVector3(-1, -phi, invPhi), SCNVector3(-1, -phi, -invPhi),
            SCNVector3(1,  phi, invPhi), SCNVector3(1,  phi, -invPhi), SCNVector3(1, -phi, invPhi), SCNVector3(1, -phi, -invPhi)
        ].map { normalize($0) } // Нормализуем для единичного размера
        
        // Индексы для 12 пентагональных граней, каждая разбита на 3 треугольника (всего 36 треугольников)
        let faceIndices: [[Int32]] = [
            [0, 4, 12, 8, 18], // Пример, нужно указать точные индексы для каждой грани
            // ... Полный список индексов вершин для каждой из 12 граней
            // Это требует точного определения, но для полноты можно использовать библиотеку или предопределенные
            // Для этого примера, пропустим полный список, но в реальном коде заполнить
        ]
        var indices: [Int32] = []
        for face in faceIndices {
            for i in 1..<face.count - 1 {
                indices.append(contentsOf: [face[0], face[i], face[i+1]])
            }
        }
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<Int32>.size)
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createIcosahedron() -> SCNGeometry {
        let t = Float((1.0 + sqrt(5.0)) / 2.0)
        let vertices: [SCNVector3] = [
            SCNVector3(-1, t, 0), SCNVector3(1, t, 0), SCNVector3(-1, -t, 0), SCNVector3(1, -t, 0),
            SCNVector3(0, -1, t), SCNVector3(0, 1, t), SCNVector3(0, -1, -t), SCNVector3(0, 1, -t),
            SCNVector3(t, 0, -1), SCNVector3(t, 0, 1), SCNVector3(-t, 0, -1), SCNVector3(-t, 0, 1)
        ].map { normalize($0) }  // ← Важно!

        let indices: [Int32] = [
            0, 11, 5, 0, 5, 1, 0, 1, 7, 0, 7, 10, 0, 10, 11,
            1, 5, 9, 5, 11, 4, 11, 10, 2, 10, 7, 6, 7, 1, 8,
            3, 9, 4, 3, 4, 2, 3, 2, 6, 3, 6, 8, 3, 8, 9,
            4, 9, 5, 2, 4, 11, 6, 2, 10, 8, 6, 7, 9, 8, 1
        ]

        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: 20, bytesPerIndex: MemoryLayout<Int32>.size)

        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    private static func createDecagonalTrapezohedron() -> SCNGeometry {
        let h: Float = 0.6   // Уменьшили высоту
        let r: Float = 0.8   // Увеличили радиус — теперь "пухлый"
        var vertices: [SCNVector3] = []

        vertices.append(SCNVector3(0, h, 0))          // Верхний полюс

        for i in 0..<10 {
            let angle = Float(i) * 2.0 * Float.pi / 10.0
            vertices.append(SCNVector3(r * cos(angle), 0.15, r * sin(angle)))  // Верхний декагон
        }

        for i in 0..<10 {
            let angle = Float(i) * 2.0 * Float.pi / 10.0 + Float.pi / 10.0
            vertices.append(SCNVector3(r * cos(angle), -0.15, r * sin(angle))) // Нижний
        }

        vertices.append(SCNVector3(0, -h, 0))         // Нижний полюс

        var indices: [Int32] = []
        for i in 0..<10 {
            let u1 = Int32(1 + i)
            let u2 = Int32(1 + (i + 1) % 10)
            let l1 = Int32(11 + i)
            let l2 = Int32(11 + (i + 1) % 10)

            indices.append(contentsOf: [0, u1, u2])
            indices.append(contentsOf: [21, l2, l1])
            indices.append(contentsOf: [u1, l1, u2])
            indices.append(contentsOf: [u2, l1, l2])
        }

        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<Int32>.size)

        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
}
