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
                .environment(\.realmConfiguration, Realm.Configuration(schemaVersion: 1))
                .preferredColorScheme(userSettings.colorScheme ? .dark : .light)
                .environmentObject(userSettings)
                .onAppear {
                    print(NSHomeDirectory())
                }
        }
    }
}
