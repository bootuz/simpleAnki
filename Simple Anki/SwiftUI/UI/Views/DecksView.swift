//
//  DecksView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI
import RealmSwift

struct DecksView: View {
    @ObservedResults(Deck.self, sortDescriptor: SortDescriptor(keyPath: "dateCreated", ascending: false)) var decks
    @State private var isNewDeckViewPresented: Bool = false
    @State private var deckName: String = ""

    var body: some View {
        NavigationView {
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
                        .controlSize(.regular)
                        .buttonStyle(.borderedProminent)
                    })
                } else {
                    List {
                        ForEach(decks) { deck in
                            NavigationLink {
                                CardsView(deck: deck)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(deck.name)
                                    cardsCount(of: deck)
                                        .font(.system(size: 11))
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    remove(deck)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        print("Test")
                    } label: {
                        Image(systemName: "tray.and.arrow.down")
                    }
                    Button {
                        isNewDeckViewPresented.toggle()
                        HapticManagerSUI.shared.impact(style: .heavy)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .alert("New deck", isPresented: $isNewDeckViewPresented) {
                        TextField("Enter deck name", text: $deckName)
                        Button("Add") {
                            addDeck()
                            deckName = ""
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {

                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func addDeck() {
        let deck = Deck(name: deckName.trimmingCharacters(in: .whitespacesAndNewlines))
        $decks.append(deck)
    }

    @ViewBuilder private func cardsCount(of deck: Deck) -> some View {
        let cardCount = deck.cards.count
        Text(cardCount == 0 ? "No cards" : "^[\(cardCount) card](inflect: true)")
    }

    private func remove(_ deck: Deck) {

        do {
            let realm = try Realm()
            guard let deckToDelete = realm.objects(Deck.self).first(where: { $0._id == deck._id }) else { return }
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
    DecksView()
}
