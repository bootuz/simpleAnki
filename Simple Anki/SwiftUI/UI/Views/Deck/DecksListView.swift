//
//  DecksView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI
import RealmSwift

struct DecksListView: View {
    @ObservedResults(
        Deck.self,
        sortDescriptor: SortDescriptor(
            keyPath: \Deck.dateCreated,
            ascending: false
        )
    ) var decks
    @State private var isNewDeckViewPresented: Bool = false
    @State private var isDeleteDialogPresented = false
    @Environment(\.realm) var realm

    var body: some View {
        NavigationStack {
            VStack {
                if decks.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No decks", systemImage: "tray")
                    }, description: {
                        Text("Your decks will appear here.")
                    }, actions: {
                        Button {
                            isNewDeckViewPresented.toggle()
                            HapticManagerSUI.shared.impact(style: .heavy)
                        } label: {
                            Text("Add deck")
                        }
                        .sheet(isPresented: $isNewDeckViewPresented) {
                            NewDeckView()
                        }
                        .controlSize(.regular)
                        .buttonStyle(.borderedProminent)
                    })
                } else {
                    List {
                        ForEach(decks) { deck in
                            NavigationLink {
                                CardsListView(deck: deck)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(deck.name)
                                    cardsCount(of: deck)
                                        .font(.system(size: 11))
                                }
                            }
                        }
                        .onDelete(perform: { indexSet in
                            for index in indexSet {
                                remove(by: decks[index]._id)
                            }
                        })
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isNewDeckViewPresented.toggle()
                        HapticManagerSUI.shared.impact(style: .heavy)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .sheet(isPresented: $isNewDeckViewPresented) {
                        NewDeckView()
                            .presentationDetents([.medium])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cardsCount(of deck: Deck) -> some View {
        let cardCount = deck.cards.count
        Text(cardCount == 0 ? "No cards" : "^[\(cardCount) card](inflect: true)")
    }

    private func remove(by deckID: ObjectId) {
        do {
            if let deckToDelete = realm.object(ofType: Deck.self, forPrimaryKey: deckID) {
                deckToDelete.cards.forEach { card in
                    LocalFileManager.shared.delete(card.audioName)
                }
                try realm.write {
                    realm.delete(deckToDelete.cards)
                    realm.delete(deckToDelete)
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

#Preview {
    DecksListView()
}
