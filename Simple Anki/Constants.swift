//
//  Constants.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 07.03.2021.
//

import Foundation


struct K {
    static let deckCellIdentifier = "decks"
    static let cardCellIdentifier = "cardCell"
    
    struct Layout {
        static let frontToBack = "frontToBack"
        static let backToFront = "backToFront"
        static let all = "all"
    }
    
    struct Settings {
        static let rateThisApp = "Rate this app"
        static let reportBug = "Report a bug"
        static let suggestFeature = "Feature suggestion"
        static let darkMode = "Dark mode"
        static let shareThisApp = "Share this app"
        static let reminderOn = "Turn on"
        
        static let support = "support"
        static let appearence = "appearence"
        static let notifications = "notifications"
    }
    
    struct Icon {
        static let lefthalf = "circle.lefthalf.fill"
        static let ladybug = "ladybug"
        static let chevron = "chevron.left.slash.chevron.right"
        static let star = "star"
        static let bell = "bell.badge"
        static let share = "square.and.arrow.up"
    }
    
    struct UserDefaultsKeys {
        static let reminder = "reminder"
        static let reminderTime = "reminderTime"
        static let darkMode = "dark_mode"
    }
    
    static let email = "help@simpleanki.com"
    static let appURL = "https://apple.co/2Sx5VC1"
}

