//
//  CardsView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 20.08.2023.
//

import SwiftUI
import RealmSwift

struct CardsListView: View {
    @ObservedRealmObject var deck: Deck
    @State private var isCardViewPresented: Bool = false
    @State private var isReviewPresented: Bool = false
    @State private var isDeckSettingsPresented: Bool = false
    @Environment(\.realm) var realm
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            if deck.cards.isEmpty {
                ContentUnavailableView(label: {
                    Label("No cards", systemImage: K.Icon.noCards)
                }, description: {
                    Text("Cards will appear here.")
                }, actions: {
                    Button {
                        isCardViewPresented.toggle()
                        HapticManagerSUI.shared.impact(style: .heavy)
                    } label: {
                        Text("Add card")
                    }
                    .controlSize(.regular)
                    .buttonStyle(.borderedProminent)
                })
            } else {
                VStack(spacing: 0) {
                    List {
                        ForEach(deck.cards) { card in
                            NavigationLink {
                                CardView(
                                    viewModel: CardViewModel(
                                        card: card,
                                        repository: CardRepository(deck: deck)
                                    ),
                                    recorder: AudioRecorder(
                                        fileName: card.audioName != nil ? card.audioName! : UUID().uuidString + ".m4a"
                                    )
                                )
                                .navigationBarBackButtonHidden()
                            } label: {
                                Text(card.front)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    remove(card)
                                } label: {
                                    Image(systemName: K.Icon.trash)
                                }
                                .tint(.red)
                            }
                        }
                        .onMove(perform: $deck.cards.move)
                    }
                    .listStyle(.plain)

                    Divider()

                    HStack(spacing: 10) {
                        Button {
                            isDeckSettingsPresented.toggle()
                            HapticManagerSUI.shared.impact(style: .heavy)
                        } label: {
                            Image(systemName: K.Icon.gearshape)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                        }
                        .tint(.blue)
                        .buttonStyle(.bordered)
                        .sheet(isPresented: $isDeckSettingsPresented, onDismiss: {
                            if deckIsRemoved(deck: deck) {
                                dismiss()
                            }
                        }, content: {
                            DeckSettingsView(deck: deck)
                                .interactiveDismissDisabled(deck.name.isEmpty)
                        })

                        Button {
                            isReviewPresented.toggle()
                            HapticManagerSUI.shared.impact(style: .heavy)
                        } label: {
                            Text("Review")
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .fullScreenCover(isPresented: $isReviewPresented) {
                            ReviewView(reviewManager: ReviewManagerSUI(deck: deck))
                        }
                    }
                    .padding()
                    .padding(.top)
                    .frame(height: 50)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isCardViewPresented.toggle()
                } label: {
                    Image(systemName: K.Icon.plusCircleFill)
                }
                .sheet(isPresented: $isCardViewPresented) {
                    NavigationView {
                        CardView(
                            viewModel: CardViewModel(repositry: CardRepository(deck: deck)),
                            recorder: AudioRecorder(fileName: UUID().uuidString + ".m4a")
                        )
                    }
                }
            }
        }
        .navigationTitle(deck.name)
    }

    private func remove(_ card: Card) {
        guard let index = findIndex(of: card) else { return }
        let audioName = deck.cards[index].audioName

        $deck.cards.remove(at: index)
        LocalFileManager.shared.delete(audioName)
    }

    private func deckIsRemoved(deck: Deck) -> Bool {
        return realm.object(ofType: Deck.self, forPrimaryKey: deck._id) == nil
    }

    private func findIndex(of card: Card) -> Int? {
        return deck.cards.firstIndex(of: card)
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardsListView(deck: Deck.deck2)
        }
    }
}
