//
//  MainView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .first

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .first:
                    NavigationStack {
                        VStack(spacing: 0) {
                            DecksListView()
                            TabBarView()
                        }
                    }
                case .second:
                    SettingsView()
                case .third:
                    Text("Third")
                }
            }

            if selectedTab != .first {
                TabBarView()
            }
        }
    }

    @ViewBuilder
    func TabBarView() -> some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Spacer()
                TabItemView(tab: .first, title: "Decks", icon: "tray.full.fill", selectedTab: $selectedTab)
                Spacer(minLength: 144)
                TabItemView(tab: .second, title: "Settings", icon: "gear", selectedTab: $selectedTab)
                Spacer()
            }
            .padding(.top, 8)
        }
        .frame(height: 50)
    }
}

#Preview {
    MainView()
}
