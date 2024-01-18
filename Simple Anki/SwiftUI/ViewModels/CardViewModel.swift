//
//  CardViewModel.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 07.01.2024.
//

import Foundation
import SwiftUI
import RealmSwift
import Observation

@Observable
final class CardViewModel {
    var frontWord: String = ""
    var backWord: String = ""
    var memorized: Bool = false
    var audioName: String?
    var image: UIImage?
    var id: ObjectId?

    var incomplete: Bool { frontWord.isEmpty }

    @ObservationIgnored
    var updating: Bool { id != nil }

    init() {}

    init(card: Card) {
        self.frontWord = card.front
        self.backWord = card.back
        self.memorized = card.memorized
        self.audioName = card.audioName
        self.image = UIImage(data: Data())
        self.id = card._id
    }

    func clear() {
        frontWord = ""
        backWord = ""
        audioName = nil
    }
}
