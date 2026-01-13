//
//  SettingsViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class SettingsViewController: BaseViewController {
    
    // MARK: - UI Elements
    private let themeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Тема"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeSegmentControl: UISegmentedControl = {
        let items = AppTheme.allCases.map { $0.displayName }
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()
    
    private let themeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateThemeSelection()
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc private func themeChanged() {
        let selectedIndex = themeSegmentControl.selectedSegmentIndex
        guard selectedIndex < AppTheme.allCases.count else { return }
        
        let selectedTheme = AppTheme.allCases[selectedIndex]
        DesignManager.shared.currentTheme = selectedTheme
    }
    
    @objc override func themeDidChange() {
        super.themeDidChange()
        updateColors()
    }
}

// MARK: - Setup
private extension SettingsViewController {
    func setupUI() {
        title = "Настройки"
        
        view.addSubview(themeContainerView)
        themeContainerView.addSubview(themeTitleLabel)
        themeContainerView.addSubview(themeSegmentControl)
        
        themeSegmentControl.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            themeContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            themeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            themeContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            themeTitleLabel.topAnchor.constraint(equalTo: themeContainerView.topAnchor, constant: 16),
            themeTitleLabel.leadingAnchor.constraint(equalTo: themeContainerView.leadingAnchor, constant: 16),
            themeTitleLabel.trailingAnchor.constraint(equalTo: themeContainerView.trailingAnchor, constant: -16),
            
            themeSegmentControl.topAnchor.constraint(equalTo: themeTitleLabel.bottomAnchor, constant: 12),
            themeSegmentControl.leadingAnchor.constraint(equalTo: themeContainerView.leadingAnchor, constant: 16),
            themeSegmentControl.trailingAnchor.constraint(equalTo: themeContainerView.trailingAnchor, constant: -16),
            themeSegmentControl.bottomAnchor.constraint(equalTo: themeContainerView.bottomAnchor, constant: -16),
            themeSegmentControl.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func updateThemeSelection() {
        let currentTheme = DesignManager.shared.currentTheme
        if let index = AppTheme.allCases.firstIndex(of: currentTheme) {
            themeSegmentControl.selectedSegmentIndex = index
        }
        updateColors()
    }
    
    func updateColors() {
        let style = DesignManager.shared.getCurrentStyle()
        themeTitleLabel.textColor = style.primaryTextColor
        themeSegmentControl.selectedSegmentTintColor = style.accentColor
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .themeDidChange,
            object: nil
        )
    }
}
