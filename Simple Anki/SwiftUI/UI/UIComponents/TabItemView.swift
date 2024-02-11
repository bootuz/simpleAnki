//
//  TabItemView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 29.01.2024.
//

import SwiftUI

struct TabItemView: View {
    let title: String
    let icon: String
    let tab: Tab

    @Binding var selectedTab: Tab

    init(tab: Tab, title: String, icon: String, selectedTab: Binding<Tab>) {
        self.tab = tab
        self.title = title
        self.icon = icon
        self._selectedTab = selectedTab
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 11))
            }
            .foregroundColor(selectedTab == tab ? .blue : .secondary)
        }
        .frame(width: 65, height: 42)
        .onTapGesture {
            selectedTab = tab
        }
    }
}

#Preview {
    TabItemView(tab: .first, title: "Decks", icon: "tray.full", selectedTab: .constant(.first))
}
