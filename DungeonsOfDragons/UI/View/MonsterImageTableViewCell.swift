//
//  MonsterImageTableViewCell.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class MonsterImageTableViewCell: UITableViewCell {
    private let monsterImageView = UIImageView()
    private let favoriteButton = UIButton(type: .system)
    
    var favoriteCompletion: ((Bool) -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with imageURLString: String, isFavorite: Bool) {
        UIImage().loadPromoImage(from: imageURLString) { [weak self] image in
            guard let self else { return }
            monsterImageView.image = image
        }
        favoriteButton.isSelected = isFavorite
    }
    
    @objc private func favoriteButtonTapped() {
        favoriteButton.isSelected.toggle()
        UIView.transition(with: favoriteButton, duration: 0.3, options: .transitionFlipFromRight) { [weak self] in
            guard let self else { return }
            favoriteCompletion?(favoriteButton.isSelected)
        }
    }

    private func setupView() {
        monsterImageView.backgroundColor = .white
        monsterImageView.contentMode = .scaleAspectFit
        monsterImageView.clipsToBounds = true
        monsterImageView.layer.cornerRadius = 8
        monsterImageView.layer.masksToBounds = true
        
        setupFavoriteButton()
        
        monsterImageView.tAMIC()
        favoriteButton.tAMIC()
        contentView.addSubview(monsterImageView)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            monsterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            monsterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            monsterImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            monsterImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            monsterImageView.heightAnchor.constraint(equalTo: monsterImageView.widthAnchor, multiplier: 1),
            
            favoriteButton.topAnchor.constraint(equalTo: monsterImageView.topAnchor, constant: 8),
            favoriteButton.rightAnchor.constraint(equalTo: monsterImageView.rightAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupFavoriteButton() {
        favoriteButton.tintColor = .clear
        
        favoriteButton.setImage(
            UIImage(systemName: "star")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            for: .normal
        )
        favoriteButton.setImage(
            UIImage(systemName: "star.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal),
            for: .selected
        )
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
}
