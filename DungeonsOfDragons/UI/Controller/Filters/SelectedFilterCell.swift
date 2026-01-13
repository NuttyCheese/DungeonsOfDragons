//
//  SelectedFilterCell.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit

final class SelectedFilterCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let removeButton = UIButton(type: .system)
    private var removeAction: (() -> Void)?
    
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
        removeAction = nil
        removeButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        removeButton.tintColor = .white
        removeButton.isEnabled = true
    }
    
    func configure(with title: String, removeAction: @escaping () -> Void) {
        titleLabel.text = title
        self.removeAction = removeAction
        removeButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
    }
    
    @objc private func removeButtonTapped() {
        removeAction?()
    }
}

private extension SelectedFilterCell {
    func setupView() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
        
        setupLabel()
        setupButton()
        
        contentView.subviewsOnView(titleLabel, removeButton)
        setupConstraints()
    }
    
    func setupLabel() {
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byClipping
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.allowsDefaultTighteningForTruncation = false
    }
    
    func setupButton() {
        removeButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        removeButton.tintColor = .white
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        [titleLabel, removeButton].forEach { $0.tAMIC() }
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
