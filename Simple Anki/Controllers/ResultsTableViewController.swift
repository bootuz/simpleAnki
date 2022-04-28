//
//  ResultsTableViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 23.06.2021.
//

import UIKit
import RealmSwift

enum Scope: String {
    case decks = "Decks"
    case cards = "Cards"
}

class ResultsTableViewController: UITableViewController {
    var originatingController: DecksTableViewController?
    var filteredDecks: Results<Deck>?
    var filteredCards: Results<Card>?
    var scope: Scope?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultsCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if scope == .decks {
            return filteredDecks?.count ?? 0
        } else {
            return filteredCards?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if scope == .decks {
            let deck = filteredDecks?[indexPath.row]
            content.text = deck?.name
        } else {
            let card = filteredCards?[indexPath.row]
            content.text = card?.front
            guard let deckName = card?.parentDeck.first?.name else { return UITableViewCell() }
            content.secondaryText = "From: \(deckName) deck"
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cardsVC = CardsTableViewController()
        if scope == .decks {
            cardsVC.selectedDeck = filteredDecks?[indexPath.row]
        } else {
            cardsVC.selectedDeck = filteredCards?[indexPath.row].parentDeck.first
            cardsVC.cardFromResult = filteredCards?[indexPath.row]
        }
        let navVC = UINavigationController(rootViewController: cardsVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension ResultsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        guard let text = searchController.searchBar.text else { return }
        filterContentForSearchText(text, scope: scope)
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String) {
        var decks: Results<Deck>?
        var cards: Results<Card>?
        if scope == Scope.cards.rawValue {
            cards = StorageManager.realm.objects(Card.self).sorted(byKeyPath: "front")
            filteredCards = cards?.filter("front CONTAINS[c] '\(searchText)'")
        } else {
            decks = StorageManager.realm.objects(Deck.self).sorted(byKeyPath: "name")
            filteredDecks = decks?.filter("name CONTAINS[c] '\(searchText)'")
        }
        self.scope = Scope(rawValue: scope)
        tableView.reloadData()
    }
}

extension ResultsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let text = searchBar.text else { return }
        guard let scope = searchBar.scopeButtonTitles?[selectedScope] else { return }
        filterContentForSearchText(text, scope: scope)
    }
}

