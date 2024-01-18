//
//  NewDeckView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 20.08.2023.
//

import SwiftUI
import RealmSwift

struct NewDeckView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var userSettings: UserSettings
    @ObservedResults(Deck.self) var decks
    @State private var deckNameText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                TextField("Name", text: $deckNameText)
                    .font(.system(size: 35, weight: .bold))
                    .padding(.top, 160)
                    .focused($isTextFieldFocused)
                Divider()
                Spacer()

                Button {
                    addDeck()
                    HapticManagerSUI.shared.impact(style: .heavy)
                    dismiss()
                } label: {
                    HStack {
                        Text("Create")
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .onAppear {
                isTextFieldFocused.toggle()
            }
            .navigationTitle("New deck")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .preferredColorScheme(userSettings.colorScheme ? .dark : .light)
    }

    private func addDeck() {
        let deck = Deck(name: deckNameText.trimmingCharacters(in: .whitespacesAndNewlines))
        $decks.append(deck)
    }
}

struct NewDeckView_Previews: PreviewProvider {
    @State static var isPresented: Bool = true

    static var previews: some View {
        NewDeckView()
            .environmentObject(UserSettings())
    }
}
