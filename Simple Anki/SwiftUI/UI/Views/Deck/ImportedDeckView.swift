//
//  ImportedDeckView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 11.02.2024.
//

import SwiftUI
import RealmSwift

struct ImportedDeckView: View {
    @ObservedResults(Deck.self, sortDescriptor: SortDescriptor(keyPath: "dateCreated", ascending: false)) var decks
    @Binding var deckName: String
    @Binding var importedCards: RealmSwift.List<Card>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Edit name") {
                    TextField("Deck name", text: $deckName)
                }
                Section("Cards") {
                    ForEach(importedCards) { card in
                        Button(action: {

                        }, label: {
                            Text("\(card.front) - \(card.back)")
                        })
                    }
                    .onDelete(perform: { indexSet in
                        importedCards.remove(atOffsets: indexSet)
                    })
                }
            }
            .navigationTitle("Imported deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        addDeck()
                        dismiss()
                    }, label: {
                        Text("Done")
                    })
                }
            }
        }
    }

    private func addDeck() {
        let deck = Deck(name: deckName)
        deck.cards = importedCards
        $decks.append(deck)
    }
}

#Preview {
    ImportedDeckView(deckName: .constant("Deck name"), importedCards: .constant(List()))
}
