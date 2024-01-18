//
//  Card.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

 import Foundation
 import RealmSwift

class Card: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var front: String
    @Persisted var back: String
    @Persisted var dateCreated: Date = Date()
    @Persisted var audioName: String?
    @Persisted var memorized: Bool = false
    @Persisted(originProperty: "cards") var deck: LinkingObjects<Deck>

    convenience init(front: String, back: String, audioName: String? = nil) {
        self.init()
        self.front = front
        self.back = back
        self.audioName = audioName
    }
}

extension Card {
    static var card: Card = Card(front: "front", back: "back")
}
