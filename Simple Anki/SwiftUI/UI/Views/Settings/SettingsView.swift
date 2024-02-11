//
//  SettingsView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject var userSettings = UserSettings()
    @State private var reminderViewModel = ReminderViewModel()
    @State private var isPresented: Bool = false
    @State private var isReminderViewPresented: Bool = false

    var body: some View {
        NavigationStack {
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

                Section("Notifications") {
                    Button(action: {
                        Task {
                            do {
                                let success = try await UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert])
                                if success {
                                    isReminderViewPresented = true
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }, label: {
                        HStack {
                            Label("Set up reminder", systemImage: "bell")
                        }
                    })
                    .tint(.primary)
                    .sheet(isPresented: $isReminderViewPresented) {
                        ReminderView()
                    }
                }

                Section("Feedback") {
                    Button(action: {
                        RateManager.rateApp()
                    }, label: {
                        Label("Review this app", systemImage: "star")
                    })
                    .tint(.primary)

                    Button(action: {
                        isPresented = true
                    }, label: {
                        Label("Contact developer", systemImage: "message")
                    })
                    .tint(.primary)
                    .confirmationDialog("", isPresented: $isPresented, actions: {
                        Link("Facebook", destination: URL(string: "https://www.facebook.com/astemirboziy")!)
                        Link("Telegram", destination: URL(string: "https://t.me/nart_kenobi")!)
                        Link("Instagram", destination: URL(string: "https://www.instagram.com/astemirboziy")!)
                        Link("Email", destination: URL(string: "mailto:astemirboziy@gmail.com")!)
                    }, message: {
                        Text("Your insights are invaluable to me! Please feel free to suggest a feature, report a bug, or share your thoughts — I'm all ears!")
                    })

                    ShareLink(item: URL(string: K.appURL)!, preview: SharePreview("Simple Anki: \(K.appURL)", image: Image("SimpleAnki"))) {
                        Label("Share Simple Anki", systemImage: "square.and.arrow.up")
                    }
                    .tint(.primary)
                }
                Section {
                    LinkView(label: "Github", urlString: "https://github.com/bootuz/simpleAnki", icon: Image("github-fill"))
                } header: {
                    Text("Source code")
                } footer: {
                    Text("Simple Anki is now open source.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
