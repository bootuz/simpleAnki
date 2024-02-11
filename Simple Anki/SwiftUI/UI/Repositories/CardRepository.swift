//
//  CardRepository.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 19.01.2024.
//

import Foundation
import RealmSwift

protocol Repository {
    associatedtype Item

    func fetchCard(by id: ObjectId) -> Item?
    func add(card: Item)
    func update(card: Item)
    func delete(by cardID: ObjectId)
}

class CardRepository: Repository {

    typealias Item = Card

    private var realm: Realm = try! Realm()
    private var deck: Deck

    init(deck: Deck) {
        self.deck = deck
    }

    func fetchCard(by id: ObjectId) -> Card? {
        return realm.object(ofType: Card.self, forPrimaryKey: id)
    }

    func add(card: Card) {
        guard let deck = fetchDeck(by: deck._id) else { return }
        try! realm.write {
            deck.cards.append(card)
        }
    }

    func update(card: Card) {
        guard let cardToUpdate = fetchCard(by: card._id) else { return }

        try! realm.write {
            cardToUpdate.front = card.front
            cardToUpdate.back = card.back
            cardToUpdate.audioName = card.audioName
            cardToUpdate.memorized = card.memorized
        }
    }

    func delete(by cardID: ObjectId) {
        guard let index = getCardIndex(by: cardID) else { return }

        let audioName = deck.cards[index].audioName

        try! realm.write {
            deck.cards.remove(at: index)
        }

        LocalFileManager.shared.delete(audioName)
    }
}

extension CardRepository {

    private func fetchDeck(by id: ObjectId) -> Deck? {
        return realm.object(ofType: Deck.self, forPrimaryKey: deck._id)
    }

    private func getCardIndex(by cardID: ObjectId) -> Int? {
        return deck.cards.firstIndex(where: { $0._id == cardID })
    }
}
