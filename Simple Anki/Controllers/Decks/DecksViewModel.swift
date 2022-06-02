//
//  DecksViewModel.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.02.2022.
//

import Foundation
import RealmSwift

enum SortType: String {
    case name = "name"
    case dateCreated = "dateCreated"
}

protocol RefreshDataDelegate: AnyObject {
    func reload()
}

class DecksViewModel {

    var decks: Results<Deck>!

    weak var delegate: RefreshDataDelegate?

    func loadDecks(by key: SortType) {
        decks = StorageManager.realm.objects(Deck.self).sorted(byKeyPath: key.rawValue, ascending: true)
        delegate?.reload()
    }

    func saveDeck(at index: Int, text: String?) {
        guard let text = text else { return }

        do {
            try StorageManager.realm.write {
                self.decks[index].name = text
            }
        } catch {
            // TODO: log error
        }
    }

    func setSort(by type: SortType) {
        UserDefaults.standard.set(type.rawValue, forKey: "sort")
    }

    func getSortType() -> SortType? {
        guard let sortType = UserDefaults.standard.string(forKey: "sort") else { return nil }
        return SortType(rawValue: sortType)
    }
}
