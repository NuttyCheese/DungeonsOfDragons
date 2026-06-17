//
//  FilterSelectionCell.swift
//  DungeonsOfDragons
//
//  Created by Борис Павлов on 13.01.2026.
//

import UIKit

final class FilterSelectionCell: UITableViewCell {
    private let checkboxView = UIView()
    private let checkmarkImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCheckbox()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        updateCheckbox(isSelected: false)
    }
    
    func configure(with title: String, isSelected: Bool) {
        textLabel?.text = title
        textLabel?.numberOfLines = 0
        
        backgroundColor = .clear
        selectionStyle = .default
        
        updateCheckbox(isSelected: isSelected)
        applyStyles()
    }
    
    func applyStyles() {
        let style = DesignManager.shared.getCurrentStyle()
        textLabel?.textColor = style.primaryTextColor
        updateCheckboxBorderColor(style: style)
    }
    
    func updateCheckboxBorderColor(style: StyleModel) {
        if checkboxView.backgroundColor == .clear {
            checkboxView.layer.borderColor = style.borderColor.withAlphaComponent(0.7).cgColor
        }
    }
}

private extension FilterSelectionCell {
    func setupCheckbox() {
        checkboxView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        checkboxView.backgroundColor = .clear
        checkboxView.layer.borderWidth = 2
        checkboxView.layer.cornerRadius = 12
        
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.isHidden = true
        
        checkboxView.addSubview(checkmarkImageView)
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkboxView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkboxView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 14),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        accessoryView = checkboxView
    }
    
    func updateCheckbox(isSelected: Bool) {
        let style = DesignManager.shared.getCurrentStyle()
        if isSelected {
            checkboxView.backgroundColor = style.accentColor
            checkboxView.layer.borderColor = style.accentColor.cgColor
            checkmarkImageView.tintColor = style.primaryTextColor
            checkmarkImageView.isHidden = false
        } else {
            checkboxView.backgroundColor = .clear
            checkboxView.layer.borderColor = style.borderColor.withAlphaComponent(0.7).cgColor
            checkmarkImageView.isHidden = true
        }
    }
}
