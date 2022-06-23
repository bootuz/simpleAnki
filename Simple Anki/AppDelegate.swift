//
//  AppDelegate.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.11.2021.
//

import UIKit
import RealmSwift
import FirebaseCore
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let userID = UUID().uuidString
        IAPManager.shared.configure { success in
            if success {
                print("Success")
                IAPManager.shared.checkPermissions()
            }
        }

        FirebaseApp.configure()
        IAPManager.shared.setUserID(id: userID)
//        Analytics.setUserID(userID)
        RateManager.incrementLaunchCount()
//        let config = Realm.Configuration(
//                    schemaVersion: 3,
//                    migrationBlock: { migration, oldSchemaVersion in
//                        if (oldSchemaVersion < 3) {
//                            migration.enumerateObjects(ofType: Card.className()) { _, newObject in
//                                newObject!["_id"] = ObjectId.generate()
//                                newObject!["memorized"] = false
//                            }
//
//                            migration.enumerateObjects(ofType: Deck.className()) { _, newObject in
//                                newObject!["_id"] = ObjectId.generate()
//                                newObject!["autoplay"] = false
//                            }
//                        }
//                    }
//        )

        do {
            StorageManager.realm = try Realm()
        } catch {
            print(error.localizedDescription)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

}
