//
//  SimpleAnkiApp.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI
import RealmSwift

@main
struct SimpleAnkiApp: SwiftUI.App {
    @StateObject var userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.realmConfiguration, Realm.Configuration(schemaVersion: 2, migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 2 {
                        migration.enumerateObjects(ofType: Deck.className()) { _, newObject in
                            newObject!["shuffled"] = false
                        }
                        migration.enumerateObjects(ofType: Card.className()) { _, newObject in
                            newObject!["image"] = nil
                        }
                    }
                }))
                .preferredColorScheme(userSettings.colorScheme ? .dark : .light)
                .onAppear {
                    print(NSHomeDirectory())
                }
        }
    }
}
