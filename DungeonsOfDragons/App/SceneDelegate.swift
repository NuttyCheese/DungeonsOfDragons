//
//  SceneDelegate.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        startToApp(windowScene: windowScene)
    }
}

private extension SceneDelegate {
    func startToApp(windowScene: UIWindowScene) {
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // Применяем сохраненную тему при запуске
        let theme = DesignManager.shared.currentTheme
        if theme == .system {
            window?.overrideUserInterfaceStyle = .unspecified
        } else {
            window?.overrideUserInterfaceStyle = theme == .dark ? .dark : .light
        }
        
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        window?.makeKeyAndVisible()
    }
}
