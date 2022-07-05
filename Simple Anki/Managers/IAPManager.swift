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

    var products: [Qonversion.Product] = []

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

    func getOfferings(completion: @escaping ([Qonversion.Product]?) -> Void) {
        Qonversion.offerings { offerings, error in
            guard error == nil else {
                completion(nil)
                return
            }
            if let products = offerings?.main?.products {
                self.products = products
                completion(products)
            }
        }
    }

    func checkPermissions(completion: @escaping (Bool) -> Void) {
        Qonversion.checkPermissions { permissions, error in
            guard error == nil else {
                completion(false)
                return
            }
            self.checkPremiumPermission(permissions: permissions, completion: completion)
        }
    }

    func checkPremiumPermission(
        permissions: [String: Qonversion.Permission],
        completion: @escaping (Bool) -> Void) {
            if let premium: Qonversion.Permission = permissions["Premium"], premium.isActive {
                completion(true)
            } else {
                completion(false)
            }
        }

    func purchase(productID: String, completion: @escaping (Bool) -> Void) {
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

    func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void) {
        Qonversion.restore { permissions, error in
            if let err = error {
                completion(.failure(err))
                return
            }
            self.checkPremiumPermission(permissions: permissions) { success in
                completion(.success(success))
            }
        }
    }

    func checkTrial(completion: @escaping (Bool) -> Void) {
        Qonversion.checkTrialIntroEligibility(forProductIds: ["annual", "monthly"]) { (result, error) in
            guard error == nil else {
                completion(false)
                return
            }
            if let intro = result["annual"], intro.status == .eligible {
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
            return "annual"
        case .durationLifetime:
            return "Lifetime"
        case .durationMonthly:
            return "monthly"
        case .durationUnknown:
            return "Unknown"
        default:
            return ""
        }
    }
}
