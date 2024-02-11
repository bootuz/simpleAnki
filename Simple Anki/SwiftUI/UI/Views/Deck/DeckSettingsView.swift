//
//  DeckSettingsView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 04.02.2024.
//

import SwiftUI
import RealmSwift

struct DeckSettingsView: View {
    @ObservedRealmObject var deck: Deck
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Name") {
                        TextField("Enter name", text: $deck.name)
                    }
                    Section("Layout") {
                        LayoutButton(labelText: "Front to Back", layout: K.Layout.frontToBack, deck: deck)
                        LayoutButton(labelText: "Back to Front", layout: K.Layout.backToFront, deck: deck)
                        LayoutButton(labelText: "Combined", layout: K.Layout.all, deck: deck)
                    }

                    Section("Pronunciation") {
                        Toggle(isOn: $deck.autoplay, label: {
                            Label("Autoplay", systemImage: deck.autoplay ? "speaker.wave.2" : "speaker.slash")
                        })
                    }

                    Section("Cards order") {
                        Toggle(isOn: $deck.shuffled, label: {
                            Label("Shuffle", systemImage: "shuffle")
                        })
                    }

                    Section {
                        Button(action: {
                            remove(deck: deck)
                        }, label: {
                            Label("Delete deck", systemImage: "trash")
                                .foregroundStyle(.red)
                        })
                        .tint(.red)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(deck.name.isEmpty)
                }
            }
            .navigationTitle("Deck settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func remove(deck: Deck) {
        guard let deckToDelete = realm.objects(Deck.self).first(where: { $0._id == deck._id }) else { return }
        do {
            deckToDelete.cards.forEach { card in
                LocalFileManager.shared.delete(card.audioName)
            }
            try realm.write {
                realm.delete(deckToDelete.cards)
                realm.delete(deckToDelete)
            }
        } catch {
            print("Error: \(error)")
        }

    }
}

#Preview {
    DeckSettingsView(deck: Deck.deck1)
}
