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
    @ObservedRealmObject var deck: Deck

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
                List {
                    ForEach(deck.cards) { card in
                        NavigationLink {
                            CardView(viewModel: CardViewModel(card: card), deck: deck)
                                .environmentObject(AudioRecorder(fileName: card.audioName))
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
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "gearshape")
                                .padding(.vertical, 8)
                        }
                        .tint(.blue)
                        .buttonStyle(.bordered)
//                        .confirmationDialog("Test", isPresented: .constant(true)) {
//
//                        }

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
                            ReviewView(reviewManager: ReviewManagerSUI(cards: deck.cards))
                        }
                    }
                    .padding()

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
                        CardView(viewModel: CardViewModel(), deck: deck)
                            .environmentObject(AudioRecorder())
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
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
