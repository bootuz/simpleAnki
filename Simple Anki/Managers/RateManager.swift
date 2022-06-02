//
//  RateManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.05.2021.
//

import UIKit
import StoreKit

class RateManager {
    private static let count = UserDefaults.standard.integer(forKey: "run_count")
    private static let appID = "id1562385336"
    private static let urlString = "https://itunes.apple.com/app/\(appID)?action=write-review"

    class func incrementLaunchCount() {
        if count < 2 {
            UserDefaults.standard.set(count + 1, forKey: "run_count")
        }
    }

    class func showRatesAlert(withoutCounter: Bool) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene  else { return }

        if withoutCounter {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            if count == 2 {
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview(in: scene)
                }
                UserDefaults.standard.set(1, forKey: "run_count")
            }
        }
    }

    class func rateApp() {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}



