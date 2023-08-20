//
//  RealmManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 18.08.2023.
//

import Foundation
import RealmSwift

protocol RealmProtocol {
    func save(deck: Deck)
    func save(_ card: Card, to deck: Deck)
    func delete(deck: Deck)
    func delete(card: Card)
    func update(deck: Deck)
    func update(card: Card)
}

class RealmManager: ObservableObject {
    private(set) var realm: Realm?
    @Published private(set) var decks: [Deck] = []

    init() {
        openRealm()
        loadDecks()
    }

    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
        } catch {
            print("Error opening Realm: \(error)")
        }
    }

    func save(deck: Deck, completion: @escaping (Bool) -> Void) {
        do {
            try realm?.write {
                realm?.add(deck)
                completion(true)
            }
        } catch {
            print("Error: \(error)")
            completion(false)
        }
    }

    func loadDecks() {
        let allDecks = realm?.objects(Deck.self).sorted(byKeyPath: "dateCreated")
        decks = []
        allDecks?.forEach { deck in
            decks.append(deck)
        }
    }

    func getDecks() {
        if let realm {
            let allDecks = realm.objects(Deck.self).sorted(byKeyPath: "dateCreated")
            decks = []
            allDecks.forEach { deck in
                decks.append(deck)
            }
        }
    }
}
