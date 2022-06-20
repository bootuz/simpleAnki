//
//  ViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.11.2021.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let decksVC = UINavigationController(rootViewController: DecksTableViewController())
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())

        let decksItem = UITabBarItem(
            title: "Decks",
            image: UIImage(systemName: "tray.full"),
            selectedImage: nil
        )
        let settingsItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            selectedImage: nil
        )

        decksVC.tabBarItem = decksItem
        settingsVC.tabBarItem = settingsItem
        self.setViewControllers([decksVC, settingsVC], animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if OnboardingManager.shared.isNewUser() {
            let onboardingVC = OnboardingViewController()
            onboardingVC.modalPresentationStyle = .popover
            onboardingVC.isModalInPresentation = true
            present(onboardingVC, animated: true)
        }
    }
}
