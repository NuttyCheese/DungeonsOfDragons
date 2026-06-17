//
//  CategoryCell.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit

final class CategoryCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        applyStyles()
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        contentView.backgroundColor = style.secondaryBackgroundColor.withAlphaComponent(0.5)
        titleLabel.textColor = style.primaryTextColor
        arrowImageView.tintColor = style.iconColor
    }
}

private extension CategoryCell {
    func setupView() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textAlignment = .left
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.subviewsOnView(titleLabel, arrowImageView)
        setupConstraints()
    }
    
    func setupConstraints() {
        [titleLabel, arrowImageView].forEach { $0.tAMIC() }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -16),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
