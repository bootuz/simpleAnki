//
//  Deck.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import Foundation
import RealmSwift

// enum Layout: String, PersistableEnum, CaseIterable {
//    case frontToBack
//    case backToFront
//    case all
// }

class Deck: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var dateCreated: Date = Date()
    @Persisted var layout: String = "frontToBack"
    @Persisted var autoplay: Bool = false
    @Persisted var cards: List<Card>

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
