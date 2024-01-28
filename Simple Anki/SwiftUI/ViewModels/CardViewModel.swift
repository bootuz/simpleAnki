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

    @ObservationIgnored
    private var cardRepository: CardRepository

    init(repositry: CardRepository) {
        self.cardRepository = repositry
    }

    init(card: Card, repository: CardRepository) {
        self.frontWord = card.front
        self.backWord = card.back
        self.memorized = card.memorized
        self.audioName = card.audioName
        self.image = UIImage(data: Data())
        self.id = card._id

        self.cardRepository = repository
    }

    func clear() {
        frontWord = ""
        backWord = ""
        audioName = nil
    }

    func addCard() {
        let card = Card(front: frontWord, back: backWord, audioName: audioName)
        cardRepository.add(card: card)
    }

    func updateCard() {
        guard let id = id else { return }
        let card = Card(front: frontWord, back: backWord, audioName: audioName)
        card._id = id
        card.memorized = memorized
        cardRepository.update(card: card)
    }

    func deleteCard() {
        guard let id = id else { return }
        cardRepository.delete(by: id)
    }
}
