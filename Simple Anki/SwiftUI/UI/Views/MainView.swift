//
//  MainView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI

struct MainView: View {

//    init() {
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//    }

    var body: some View {
        TabView {
            DecksView()
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

#Preview {
    MainView()
}

// struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
// }
