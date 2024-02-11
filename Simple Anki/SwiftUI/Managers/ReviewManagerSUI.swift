//
//  ReviewManagerSUI.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 03.09.2023.
//

import Foundation
import RealmSwift

@Observable
class ReviewManagerSUI {
    var currentCard: Card?
    var isReviewing = false

    var isAutoplayOn: Bool {
        return deck.autoplay
    }

    private var currentIndex = 0
    private var deck: Deck
    private var cards: [Card]

    init(deck: Deck) {
        self.deck = deck

        if deck.shuffled {
            self.cards = deck.cards.shuffled()
        } else {
            self.cards = Array(deck.cards)
        }
    }

    func startReview() {
        guard !deck.cards.isEmpty else {
            return
        }

        currentIndex = 0
        currentCard = self.cards[currentIndex]
        isReviewing = true
    }

    func nextCard() {
        currentIndex += 1

        if currentIndex < self.cards.count {
            currentCard = self.cards[currentIndex]
        } else {
            isReviewing = false
        }
    }
}
