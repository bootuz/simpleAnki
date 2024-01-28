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
        configureTabBar()
//        showOnboardingScreen()
    }

    private func configureTabBar() {
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

    private func showLoadingScreen() {
        let loadingScreen = LaunchScreenViewController()
        loadingScreen.delegate = self
        loadingScreen.modalPresentationStyle = .fullScreen
        present(loadingScreen, animated: false)
    }
}

extension MainTabBarViewController: DoneDelegate {
    func vewController(isDismissed: Bool) {
        if isDismissed && OnboardingManager.shared.isNewUser() {
            showOnboardingScreen()
        }
    }

    private func showOnboardingScreen() {
        let onboardingVC = OnboardingViewController()
        let navVC = UINavigationController(rootViewController: onboardingVC)
        onboardingVC.modalPresentationStyle = .popover
        onboardingVC.isModalInPresentation = true
        present(navVC, animated: true)
    }
}
