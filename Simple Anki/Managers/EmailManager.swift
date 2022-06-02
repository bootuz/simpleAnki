//
//  EmailManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 22.06.2021.
//

import UIKit

class EmailManager {

    private static var emailUrl: URL!

    static func prepareEmailForBugReport() {
        let subject = "Bug report. App version: \(String(describing: UIApplication.version))".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        prepareEmailUrl(with: subject)
        UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
    }

    static func prepareEmailForFeatureSuggestion() {
        let subject = "Feature request".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        prepareEmailUrl(with: subject)
        UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
    }

    private static func prepareEmailUrl(with subject: String) {
        emailUrl = URL(string: "mailto:\(K.email)?subject=\(subject)")!
    }
}
