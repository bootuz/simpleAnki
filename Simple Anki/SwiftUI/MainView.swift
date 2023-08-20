//
//  MainView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI

struct MainView: View {
    @StateObject var realmManager = RealmManager()

    var body: some View {
        TabView {
            DecksView()
                .environmentObject(realmManager)
                .tabItem {
                    Image(systemName: "tray.full")
                    Text("Decks")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
