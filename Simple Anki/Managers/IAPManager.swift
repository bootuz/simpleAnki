//
//  IAPManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 22.06.2022.
//

import Foundation
import Qonversion

class IAPManager {

    static let shared = IAPManager()
    var isActive: Bool = false

    private init() {}

    func configure(completion: @escaping (Bool) -> Void) {
        Qonversion.launch(withKey: "03jxfwE_jWj7KuNih8dI21UQnXci5RC5") { _, error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    func getOfferings(completion: @escaping (Qonversion.Offering?) -> Void) {
        Qonversion.offerings { offerings, error in
            guard error == nil else {
                completion(nil)
                return
            }
            if let offering = offerings?.offering(forIdentifier: "main") {
                completion(offering)
            }
        }
    }

    func checkPermissions(completion: @escaping (Bool) -> Void) {
        Qonversion.checkPermissions { permissions, error in
            guard error == nil else {
                completion(false)
                return
            }
            print(permissions)
            if let premium = permissions["Premium"], premium.isActive {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func purchase(productID: String = "monthly", completion: @escaping (Bool) -> Void) {
        Qonversion.purchase(productID) { _, error, cancelled in
            guard error == nil else {
                completion(false)
                return
            }
            if cancelled {
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Qonversion.restore { _, error in
            guard error == nil else {
                completion(false)
                return
            }
        }
    }

    func checkTrial(completion: @escaping (Bool) -> Void) {
        Qonversion.checkTrialIntroEligibility(forProductIds: ["six_months", "year", "monthly"]) { (result, error) in
            guard error == nil else {
                completion(false)
                return
            }
            if let productIntroEligibility = result.first?.value,
               productIntroEligibility.status == .eligible {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func setUserID(id: String) {
        Qonversion.setProperty(.userID, value: id)
    }
}

extension Qonversion.Product {
    var prettyDuration: String {
        switch duration {
        case .durationWeekly:
            return "weekly"
        case .duration3Months:
            return "3 months"
        case .duration6Months:
            return  "6 months"
        case .durationAnnual:
            return "year"
        case .durationLifetime:
            return "Lifetime"
        case .durationMonthly:
            return "monthly"
        case .durationUnknown:
            return "Unknown"
        @unknown default:
            return ""
        }
    }
}
