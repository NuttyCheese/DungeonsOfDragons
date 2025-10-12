//
//  MainViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit
import SwiftUI

final class MainViewController: BaseViewController {
    private let monsterImageView = UIImageView()
    private let diceImageView = UIImageView()
    private let spellsImageView = UIImageView()
    private let mainHorizontalStackView = UIStackView()
    
    private let favoriteImageView = UIImageView()
    private let settingsImageView = UIImageView()
    private let addHorizontalStackView = UIStackView()
    
    private let monsterLabel = UILabel()
    private let diceLabel = UILabel()
    private let spellsLabel = UILabel()
    private let favoriteLabel = UILabel()
    private let settingsLabel = UILabel()
    
    private let monsterStack = UIStackView()
    private let diceStack = UIStackView()
    private let spellsStack = UIStackView()
    private let favoriteStack = UIStackView()
    private let settingsStack = UIStackView()
    
    private var diceHostingController: UIHostingController<DiceModalView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func pressToImage(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? UIStackView else { return }
        
        switch tappedView.tag {
            case 1:
                let vc = MonsterListViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 2:
                showDiceModal()
            case 3:
                let vc = SpellListViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 4:
                let vc = FavoriteListViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 5:
                let vc = SettingsViewController()
                navigationController?.pushViewController(vc, animated: true)
            default: break
        }
    }
}

private extension MainViewController {
    func setupView() {
        setupMainStackView()
        setupAddStackView()
        setupIconStacks()
        setupImagesAndLabels()
        
        view.subviewsOnView(mainHorizontalStackView, addHorizontalStackView)
        
        setupConstraints()
    }
    
    func setupMainStackView() {
        mainHorizontalStackView.axis = .horizontal
        mainHorizontalStackView.spacing = 16
        mainHorizontalStackView.alignment = .center
        mainHorizontalStackView.distribution = .equalSpacing
        
        mainHorizontalStackView.subviewsOnStackView(monsterStack, diceStack, spellsStack)
    }
    
    func setupAddStackView() {
        addHorizontalStackView.axis = .horizontal
        addHorizontalStackView.spacing = 16
        addHorizontalStackView.alignment = .center
        addHorizontalStackView.distribution = .equalCentering
        
        addHorizontalStackView.subviewsOnStackView(favoriteStack, settingsStack)
    }
    
    func setupIconStacks() {
        let stacks: [(UIStackView, Int)] = [
            (monsterStack, 1),
            (diceStack, 2),
            (spellsStack, 3),
            (favoriteStack, 4),
            (settingsStack, 5)
        ]
        
        stacks.forEach { stack, tag in
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .center
            stack.tag = tag
            stack.enable()
            stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressToImage)))
        }
    }
    
    func setupImagesAndLabels() {
        let items: [(UIImageView, UILabel, UIStackView, UIImage?, String)] = [
            (monsterImageView, monsterLabel, monsterStack, Images.monsters.image, "Monsters"),
            (diceImageView, diceLabel, diceStack, Images.dice.image, "Dice"),
            (spellsImageView, spellsLabel, spellsStack, Images.spells.image, "Spells"),
            (favoriteImageView, favoriteLabel, favoriteStack, Images.favorites.image, "Favorites"),
            (settingsImageView, settingsLabel, settingsStack, Images.settings.image, "Settings")
        ]
        
        items.forEach { imageView, label, stack, image, text in
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            
            label.text = text
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            
            stack.subviewsOnStackView(imageView, label)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    }

    private func showDiceModal() {
        guard diceHostingController == nil else { return }

        let isPresented = Binding(
            get: { self.diceHostingController != nil },
            set: { newValue in
                if !newValue {
                    self.dismissDiceModal()
                }
            }
        )

        let diceView = DiceModalView(isPresented: isPresented)
        let hostingController = UIHostingController(rootView: diceView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(hostingController)
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
        self.diceHostingController = hostingController
    }

    func dismissDiceModal() {
        guard let hostingController = diceHostingController else { return }

        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()

        diceHostingController = nil
    }
}

private extension MainViewController {
    func setupConstraints() {
        [mainHorizontalStackView, addHorizontalStackView].forEach { $0.tAMIC() }
        
        NSLayoutConstraint.activate([
            mainHorizontalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainHorizontalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainHorizontalStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            addHorizontalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addHorizontalStackView.topAnchor.constraint(equalTo: mainHorizontalStackView.bottomAnchor, constant: 8),
            addHorizontalStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
        ])
    }
}
