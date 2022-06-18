//
//  OnboardingManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 18.06.2022.
//

import Foundation

class OnboardingManager {

    static let shared = OnboardingManager()

    private init() {}

    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")

    }

    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}
