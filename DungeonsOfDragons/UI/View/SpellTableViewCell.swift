//
//  SpellTableViewCell.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class SpellTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let iconButton = UIButton(type: .system)
    private var dataModel: SpellModel?
    
    var favoriteCompletion: ((SpellModel, Bool) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func confuguration(_ data: SpellModel, isFavorite: Bool) {
        dataModel = data
        
        let name = data.name
        let nameEn = data.nameEn
        
        let attributedString = NSMutableAttributedString(
            string: "\(name ?? "Unknown")\n",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        let nameEnString = NSAttributedString(
            string: "\(nameEn ?? "Unknown")",
            attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 12)
            ]
        )
        attributedString.append(nameEnString)
        titleLabel.attributedText = attributedString
    }
    
    @objc private func iconButtonTapped() {
        iconButton.isSelected.toggle()
        UIView.transition(with: iconButton, duration: 0.3, options: .transitionFlipFromRight) { [weak self] in
            guard let self, let dataModel else { return }
            favoriteCompletion?(dataModel, iconButton.isSelected)
        }
    }
}

private extension SpellTableViewCell {
    func setupView() {
        containerView.backgroundColor = .black
        containerView.layer.cornerRadius = 8
        
        setupLabel()
        setupIconButton()
        
        contentView.subviewsOnView(containerView)
        containerView.subviewsOnView(titleLabel, iconButton)
        setupConstraints()
    }
    
    func setupLabel() {
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16)
    }
    
    func setupIconButton() {
        iconButton.tintColor = .clear
        
        iconButton.setImage(
            UIImage(systemName: "star")?.withTintColor(.white, renderingMode: .alwaysOriginal),
            for: .normal
        )
        iconButton.setImage(
            UIImage(systemName: "star.fill")?.withTintColor(.yellow, renderingMode: .alwaysOriginal),
            for: .selected
        )
        iconButton.addTarget(self, action: #selector(iconButtonTapped), for: .touchUpInside)
    }
}

private extension SpellTableViewCell {
    func setupConstraints() {
        [containerView, titleLabel, iconButton].forEach { $0.tAMIC() }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: iconButton.leftAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            
            iconButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8),
            iconButton.heightAnchor.constraint(equalToConstant: 24),
            iconButton.widthAnchor.constraint(equalTo: iconButton.heightAnchor, multiplier: 1)
        ])
    }
}
