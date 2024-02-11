//
//  CardsView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 20.08.2023.
//

import SwiftUI
import RealmSwift

struct CardsView: View {
    @State private var isCardViewPresented: Bool = false
    @State private var isReviewPresented: Bool = false
    @State private var isLayoutDialogPresented: Bool = false
    @ObservedRealmObject var deck: Deck
    @Environment(\.realm) var realm

    var body: some View {
        ZStack {
            if deck.cards.isEmpty {
                ContentUnavailableView(label: {
                    Label("No cards", systemImage: "rectangle.portrait.on.rectangle.portrait.angled")
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
                                    viewModel: CardViewModel(card: card, repository: CardRepository(deck: deck)),
                                    recorder: AudioRecorder(fileName: card.audioName != nil ? card.audioName! : UUID().uuidString + ".m4a")
                                )
                                .navigationBarBackButtonHidden()
                            } label: {
                                Text(card.front)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    remove(card)
                                } label: {
                                    Image(systemName: "trash")
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
                            isLayoutDialogPresented.toggle()
                            HapticManagerSUI.shared.impact(style: .heavy)
                        } label: {
                            Image(systemName: "gearshape")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                        }
                        .tint(.blue)
                        .buttonStyle(.bordered)
                        .sheet(isPresented: $isLayoutDialogPresented, content: {
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
                    Image(systemName: "plus.circle.fill")
                }
                .sheet(isPresented: $isCardViewPresented) {
                    NavigationView {
                        CardView(viewModel: CardViewModel(repositry: CardRepository(deck: deck)), recorder: AudioRecorder(fileName: UUID().uuidString + ".m4a"))
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

    private func findIndex(of card: Card) -> Int? {
        return deck.cards.firstIndex(of: card)
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardsView(deck: Deck.deck2)
        }
    }
}
