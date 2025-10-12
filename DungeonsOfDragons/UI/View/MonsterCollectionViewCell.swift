//
//  MonsterCollectionViewCell.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class MonsterCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let iconButton = UIButton(type: .system)
    private var dataModel: MonsterModel?
    
    var favoriteCompletion: ((MonsterModel, Bool) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data: MonsterModel, isFavorite: Bool) {
        dataModel = data
        
        UIImage().loadPromoImage(from: data.imgStaticURL) { [weak self] image in
            guard let self else { return }
            imageView.image = image
        }
        
        titleLabel.text = data.name
        iconButton.isSelected = isFavorite
    }
    
    @objc private func iconButtonTapped() {
        iconButton.isSelected.toggle()
        UIView.transition(with: iconButton, duration: 0.3, options: .transitionFlipFromRight) { [weak self] in
            guard let self, let dataModel else { return }
            favoriteCompletion?(dataModel, iconButton.isSelected)
        }
    }
}

private extension MonsterCollectionViewCell {
    func setupView() {
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = 8
        
        setupLabel()
        setupImageView()
        setupButton()
        
        contentView.subviewsOnView(imageView, titleLabel, iconButton)
        
        setupConstraints()
    }
    
    func setupLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
    }
    
    func setupImageView() {
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
    }
    
    func setupButton() {
        iconButton.tintColor = .clear
        
        iconButton.setImage(
            UIImage(systemName: "star")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            for: .normal
        )
        iconButton.setImage(
            UIImage(systemName: "star.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal),
            for: .selected
        )
        iconButton.addTarget(self, action: #selector(iconButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        [imageView, titleLabel, iconButton].forEach { $0.tAMIC() }
        
        NSLayoutConstraint.activate([
            // Image View
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            // Star Image View
            iconButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            
            iconButton.widthAnchor.constraint(equalToConstant: 24),
            iconButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

