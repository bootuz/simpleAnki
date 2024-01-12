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
    @State private var isPopoverPresented: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if decks.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 100, weight: .light))
                        Text("There are no decks yet")
                    }
                    .foregroundColor(.gray.opacity(0.7))
                    Spacer()
                    Button {
                        isPopoverPresented.toggle()
                        HapticManagerSUI.shared.impact(style: .heavy)
                    } label: {
                        Text("Create deck")
                            .padding(8)
                            .frame(maxWidth: 280)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 40)
                    .sheet(isPresented: $isPopoverPresented, content: {
                        NewDeckView()
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
                                    $decks.remove(deck)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
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
                        isPopoverPresented.toggle()
                        HapticManagerSUI.shared.impact(style: .heavy)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .popover(isPresented: $isPopoverPresented) {
                        NewDeckView()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder private func cardsCount(of deck: Deck) -> some View {
        let cardCount = deck.cards.count
        if cardCount == 0 {
            Text("No cards")
        } else {
            Text("^[\(cardCount) card](inflect: true)")
        }
    }
}

struct DecksView_Previews: PreviewProvider {
    static var previews: some View {
        DecksView()
    }
}
