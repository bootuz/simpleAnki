//
//  ReviewManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 31.03.2021.
//

import Foundation

struct ReviewCard {
    let front: String
    let back: String?
    let audioName: String?
}

class ReviewManager {
    let layout: String!
    let autoPlay: Bool!
    var cardsForReview = [ReviewCard]()
    var alreadyReviewed = [ReviewCard]()
    var numberOfCards: Int64?
    var currentCard: ReviewCard?

    init(layout: String, autoPlay: Bool, cards: [Card]) {
        self.layout = layout
        self.autoPlay = autoPlay
        prepareCards(cards: cards)
        pickCard()
        cardsForReview.shuffle()
    }

    func prepareCards(cards: [Card]) {
        if layout == K.Layout.all {
            for card in cards {
                all(with: card)
            }
        } else if layout == K.Layout.backToFront {
            for card in cards {
                backToFront(with: card)
            }
        } else {
            for card in cards {
                frontToBack(with: card)
            }
        }
        numberOfCards = Int64(cardsForReview.count)
    }

    private func all(with card: Card) {
        frontToBack(with: card)
        backToFront(with: card)
    }

    private func backToFront(with card: Card) {
        cardsForReview.append(ReviewCard(front: card.back, back: card.front, audioName: card.audioName))
    }

    private func frontToBack(with card: Card) {
        cardsForReview.append(ReviewCard(front: card.front, back: card.back, audioName: card.audioName))
    }

    func pickCard() {
        if !cardsForReview.isEmpty {
            currentCard = cardsForReview.popLast()
            alreadyReviewed.append(currentCard!)
        } else {
            currentCard = nil
        }
    }

    func repeatReview() {
        alreadyReviewed.shuffle()
        cardsForReview.append(contentsOf: alreadyReviewed)
        alreadyReviewed.removeAll()
    }
}
