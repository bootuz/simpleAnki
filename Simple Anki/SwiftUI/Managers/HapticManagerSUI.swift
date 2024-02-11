//
//  HapticManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 30.08.2023.
//

import Foundation
import SwiftUI

class HapticManagerSUI {

    static let shared = HapticManagerSUI()

    private init() { }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
