//
//  MonsterImageTableViewCell.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class MonsterImageTableViewCell: UITableViewCell {
    private let monsterImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with imageURLString: String) {
        UIImage().loadPromoImage(from: imageURLString) { [weak self] image in
            guard let self else { return }
            monsterImageView.image = image
        }
    }

    private func setupView() {
        monsterImageView.backgroundColor = .white
        monsterImageView.contentMode = .scaleAspectFit
        monsterImageView.clipsToBounds = true
        monsterImageView.layer.cornerRadius = 8
        monsterImageView.layer.masksToBounds = true
        
        monsterImageView.tAMIC()
        contentView.addSubview(monsterImageView)

        NSLayoutConstraint.activate([
            monsterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            monsterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            monsterImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            monsterImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            monsterImageView.heightAnchor.constraint(equalTo: monsterImageView.widthAnchor, multiplier: 1)
        ])
    }
}
