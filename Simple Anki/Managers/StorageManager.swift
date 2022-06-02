//
//  StorageManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 01.03.2021.
//

import Foundation
import RealmSwift

class StorageManager {

    static var realm: Realm!

    static func save(_ card: Card, to deck: Deck?) {
        try! realm.write {
            deck?.cards.append(card)
        }
    }

    static func update(_ card: Card, with newCard: Card) {
        try! realm.write {
            card.front = newCard.front
            card.back = newCard.back
            card.audioName = newCard.audioName
        }
    }

    static func save(_ deck: Deck) {
        try! realm.write {
            realm.add(deck)
        }
    }

    static func deleteCard(at index: Int, from deck: Deck?) {
        let card = deck?.cards[index]
        if let name = card?.audioName {
            Utils.deleteAudioFile(with: name)
        }
        try! realm.write {
            deck?.cards.remove(at: index)
        }
    }

    static func delete(_ card: Card) {
        if let name = card.audioName {
            Utils.deleteAudioFile(with: name)
        }
        try! realm.write {
            realm.delete(card)
        }
    }

    static func delete(_ deck: Deck) {
        try! realm.write {
            deck.cards.forEach { card in
                if let name = card.audioName {
                    Utils.deleteAudioFile(with: name)
                }
                realm.delete(card)
            }
            realm.delete(deck)
        }
    }
}
