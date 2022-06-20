//
//  SceneDelegate.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.11.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarViewController()
        window.makeKeyAndVisible()
        self.window = window

        let darkModeIsOn = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.darkMode)
        if darkModeIsOn {
            self.window?.overrideUserInterfaceStyle = .dark
        } else {
            self.window?.overrideUserInterfaceStyle = .light
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
