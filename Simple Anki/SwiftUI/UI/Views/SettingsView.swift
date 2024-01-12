//
//  SettingsView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings
    var body: some View {
        NavigationView {
            List {
                Section("appearance") {
                    HStack {
                        Label {
                            Text("Dark mode")
                        } icon: {
                            Image(systemName: "circle.lefthalf.filled")
                        }
                        Spacer()
                        Toggle(isOn: $userSettings.colorScheme) {}
                    }
                }

                Section("Feedback") {
                    LinkView(
                        label: "Review app",
                        urlString: Constants.Links.writeReview,
                        icon: Image(systemName: "star")
                    )
                    LinkView(
                        label: "Contact developer",
                        urlString: Constants.Links.igMeLink,
                        icon: Image(systemName: "envelope")
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSettings())
    }
}
