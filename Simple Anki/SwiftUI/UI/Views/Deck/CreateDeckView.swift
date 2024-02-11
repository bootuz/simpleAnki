//
//  CreateDeckView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 11.02.2024.
//

import SwiftUI
import RealmSwift

struct CreateDeckView: View {
    @ObservedResults(Deck.self, sortDescriptor: SortDescriptor(keyPath: "dateCreated", ascending: false)) var decks
    @State private var deckName: String = ""
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section("Deck name") {
                TextField("Enter deck name", text: $deckName)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        createDeck()
                    }
                    .onAppear {
                        isFocused = true
                    }
            }

            Section {
                Button(action: {
                    createDeck()
                    HapticManagerSUI.shared.impact(style: .heavy)
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Create deck")
                        Spacer()
                    }
                })
                .disabled(deckName.isEmpty)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Done")
                })
            }
        }
    }

    private func createDeck() {
        let name = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
        let deck = Deck(name: name)
        $decks.append(deck)
        deckName = ""
    }
}

#Preview {
    NavigationStack {
        CreateDeckView()
    }
}
