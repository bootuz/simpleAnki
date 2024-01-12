//
//  CardsView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 20.08.2023.
//

import SwiftUI
import RealmSwift

struct CardsView: View {
    @State private var isNewCardPresented: Bool = false
    @State private var isReviewPresented: Bool = false
    @ObservedRealmObject var deck: Deck

    var body: some View {
        VStack {
            if deck.cards.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                        .font(.system(size: 100, weight: .light))
                    Text("There are no cards yet")
                }
                .foregroundColor(.gray.opacity(0.7))
                Spacer()
                Button {
                    isNewCardPresented.toggle()
                    HapticManagerSUI.shared.impact(style: .heavy)
                } label: {
                    Text("Add card")
                        .padding(8)
                        .frame(maxWidth: 280)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
                .sheet(isPresented: $isNewCardPresented, content: {
                    NavigationView {
                        NewCardView(deck: deck)
                            .environmentObject(AudioRecorder())
                    }
                })
            } else {
                ZStack {
                    List {
                        ForEach(deck.cards) { card in
                            NavigationLink {
                                CardView(card: card)
                                    .environmentObject(AudioRecorder())
                            } label: {
                                Text(card.front)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    guard let item = deck.thaw() else { return }
                                    guard item.isInvalidated else { return }
                                    item.realm?.delete(card)
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
                            Spacer()
                            Button {
                                isReviewPresented.toggle()
                                HapticManagerSUI.shared.impact(style: .heavy)
                            } label: {
                                Image(systemName: "rectangle.stack.badge.play.fill")
                                    .font(.system(size: 30))
                                    .padding(8)
                            }
                            .padding()
                            .padding(.bottom)
                            .buttonStyle(CircleButton())
                            .fullScreenCover(isPresented: $isReviewPresented) {
                                ReviewView(reviewManager: ReviewManagerSUI(deck: deck))
                            }
                        }
                    }

                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isNewCardPresented.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .popover(isPresented: $isNewCardPresented) {
                    NavigationView {
                        NewCardView(deck: deck)
                            .environmentObject(AudioRecorder())
                    }
                }
            }
        }
        .navigationTitle(deck.name)
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardsView(deck: Deck.deck2)
        }
    }
}
