//
//  SectionHeaderView.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit

final class SectionHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        applyStyles()
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        titleLabel.textColor = style.primaryTextColor
    }
}

private extension SectionHeaderView {
    func setupView() {
        backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        addSubview(titleLabel)
        titleLabel.tAMIC()
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
