//
//  BaseViewController.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

class BaseViewController: UIViewController {
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupObservers()
        let style = DesignManager.shared.getCurrentStyle()
        applyNavigationBarStyles(style: style)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc func themeDidChange() {
        setupGradientBackground()
        let style = DesignManager.shared.getCurrentStyle()
        view.backgroundColor = style.backgroundColor
        applyNavigationBarStyles(style: style)
    }
    
    func applyNavigationBarStyles(style: StyleModel) {
        navigationController?.navigationBar.tintColor = style.accentColor
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: style.primaryTextColor
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: style.primaryTextColor
        ]
    }
}

private extension BaseViewController {
    func setupGradientBackground() {
        let style = DesignManager.shared.getCurrentStyle()
        
        if gradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
            view.layer.insertSublayer(gradient, at: 0)
            self.gradientLayer = gradient
        }
        
        gradientLayer?.frame = view.bounds
        gradientLayer?.colors = [
            style.gradientStartColor.cgColor,
            style.gradientEndColor.cgColor
        ]
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
