//
//  HapticManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 11.06.2021.
//

import UIKit

final class HapticManager {
    
    static let shared = HapticManager()
    
    private init() {}
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(type)
    }
}
