//
//  ReviewManagerSUI.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 03.09.2023.
//

import Foundation
import RealmSwift

class ReviewManagerSUI: ObservableObject {
    @Published var currentCard: Card?
    @Published var isReviewing = false
    var isAutoplayOn: Bool {
        return deck.autoplay
    }

    private var currentIndex = 0
    private var deck: Deck

    init(deck: Deck) {
        self.deck = deck
    }

    func startReview() {
        guard !deck.cards.isEmpty else {
            return
        }

        currentIndex = 0
        currentCard = deck.cards[currentIndex]
        isReviewing = true
    }

    func nextCard() {
        currentIndex += 1

        if currentIndex < deck.cards.count {
            currentCard = deck.cards[currentIndex]
        } else {
            isReviewing = false
        }
    }
}
