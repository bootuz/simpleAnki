//
//  ImoptedDeckViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 09.05.2022.
//

import UIKit
import FirebaseAnalytics

class ImportedCardsCollectionViewController: UIViewController {

    var collectionView: UICollectionView!
    var importedCards: [Cards]?
    var deckName: String?
    var reloadData: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preview imported cards"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didSaveTapped))
        configureCollectionView()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self

    }

    @objc private func didSaveTapped() {
        guard let deckName = deckName, let cards = importedCards else {
            return
        }
        let newDeck = Deck()
        newDeck.name = deckName
        for card in cards {
            let newCard = Card()
            newCard.front = card.front
            newCard.back = card.back
            newDeck.cards.append(newCard)
        }
        Analytics.logEvent("impored_deck", parameters: [
            "name" : deckName as NSObject,
            "cards_number" : cards.count as NSObject
        ])
        StorageManager.save(newDeck)
        reloadData?()
        self.view.window?.rootViewController?.dismiss(animated: true)
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 70, right: 16)
        layout.itemSize = CGSize(width: view.frame.width, height: 200)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsSelection = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.register(ImportedCardCollectionViewCell.self, forCellWithReuseIdentifier: ImportedCardCollectionViewCell.identifier)
    }
}

extension ImportedCardsCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return importedCards?.count ?? 0
    }
}

extension ImportedCardsCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImportedCardCollectionViewCell.identifier, for: indexPath)
                as? ImportedCardCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: importedCards?[indexPath.row])
        return cell
    }
}
