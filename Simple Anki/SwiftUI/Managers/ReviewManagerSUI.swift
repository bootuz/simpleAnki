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

    private var cards: List<Card>
    private var currentIndex = 0

    init(cards: List<Card>) {
        self.cards = cards
    }

    func startReview() {
        guard !cards.isEmpty else {
            return
        }

        currentIndex = 0
        currentCard = cards[currentIndex]
        isReviewing = true
    }

    func nextCard() {
        currentIndex += 1

        if currentIndex < cards.count {
            currentCard = cards[currentIndex]
        } else {
            isReviewing = false
        }
    }
}
