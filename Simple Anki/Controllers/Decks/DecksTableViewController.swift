//
//  DecksTableViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.11.2021.
//

import UIKit
import RealmSwift
import SwiftCSV
import FirebaseAnalytics

class DecksTableViewController: UITableViewController {

    var viewModel = DecksViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Decks"
        navigationController?.navigationBar.prefersLargeTitles = true
        congigureBarButtonItems()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let key = viewModel.getSortType() ?? .dateCreated
        viewModel.loadDecks(by: key)
    }

    @objc func didTapImport() {
        let reminderVC = ImportViewController()
        let nav = UINavigationController(rootViewController: reminderVC)
        nav.isModalInPresentation = true
        if let sheetController = nav.sheetPresentationController {
            sheetController.detents = [.medium()]
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(nav, animated: true)
    }

    @objc private func didTapPlus() {
        didTapCreateDeck()
    }

    @objc func didTapCreateDeck() {
        let newDeckVC = NewDeckViewController()
        newDeckVC.reloadData = { [weak self] in
            self?.reload()
        }
        let navVC = UINavigationController(rootViewController: newDeckVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }

    // MARK: - Configure UI

    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.deckCellIdentifier)
        viewModel.delegate = self
    }

    private func congigureBarButtonItems() {
        let barButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "plus"),
                style: .plain,
                target: self,
                action: #selector(didTapPlus)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "tray.and.arrow.down"),
                style: .plain,
                target: self,
                action: #selector(didTapImport)
            )
        ]
        navigationItem.rightBarButtonItems = barButtonItems
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let decksCount = viewModel.decks?.count {
            switch decksCount {
            case 0:
                setEmptyState()
            default:
                restore()
            }
        }
        return viewModel.decks?.count ?? 0
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [makeDeleteContextualAction(forRowAt: indexPath)])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    override func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [makeEditDeckNameContextualAction(forRowAt: indexPath)])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let deleteContextualAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            let deck = self.viewModel.decks[indexPath.row]
            StorageManager.delete(deck)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteContextualAction.image = UIImage(systemName: "trash")
        return deleteContextualAction
    }

    private func makeEditDeckNameContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let editContextualAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completion) in
            var textField = UITextField()
            let alert = UIAlertController(title: "Edit deck's name", message: "", preferredStyle: .alert)

            let editAction = UIAlertAction(title: "Change", style: .default) { (_) in
                let deckName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                if !deckName!.isEmpty {
                    self.viewModel.saveDeck(at: indexPath.row, text: textField.text)
                }
                self.tableView.reloadData()
            }
            alert.addAction(editAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelAction)

            alert.addTextField { [weak self] (deckTextField) in
                NotificationCenter.default.addObserver(
                    forName: UITextField.textDidChangeNotification,
                    object: deckTextField,
                    queue: OperationQueue.main) { _ in
                        let deckName = deckTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                        editAction.isEnabled = !deckName!.isEmpty
                    }
                deckTextField.autocapitalizationType = .sentences
                deckTextField.placeholder = "Type new name"
                textField = deckTextField
                textField.text = self?.viewModel.decks[indexPath.row].name
                textField.clearButtonMode = .whileEditing
            }

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }

            completion(true)
        }

        editContextualAction.backgroundColor = .systemBlue
        editContextualAction.image = UIImage(systemName: "pencil")
        return editContextualAction
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.deckCellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let deck = viewModel.decks[indexPath.row]
        content.text = deck.name
        let cardsCount = deck.cards.count
        switch cardsCount {
        case 0:
            content.secondaryText = "No cards yet"
        case 1:
            content.secondaryText = "\(cardsCount) card"
        default:
            content.secondaryText = "\(cardsCount) cards"
        }

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cardsVC = CardsTableViewController()
        if let indexPath = tableView.indexPathForSelectedRow {
            cardsVC.selectedDeck = viewModel.decks[indexPath.row]
        }
        let navVC = UINavigationController(rootViewController: cardsVC)
        navVC.modalPresentationStyle = .fullScreen
        tableView.deselectRow(at: indexPath, animated: true)
        present(navVC, animated: true)
    }
}

extension DecksTableViewController: RefreshDataDelegate {
    func reload() {
        tableView.reloadData()
    }
}

extension DecksTableViewController: EmptyState {
    func setEmptyState() {
        let imageView = UIImageView(image: UIImage(systemName: "tray"))
        imageView.center = CGPoint(x: view.frame.width / 2,
                                   y: view.frame.height / 2)
        imageView.bounds.size = CGSize(width: imageView.bounds.size.width * 5,
                                       height: imageView.bounds.size.height * 5)
        imageView.tintColor = .systemGray3

        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                 width: view.frame.width,
                                                 height: view.frame.height))
        messageLabel.center = CGPoint(x: view.frame.width / 2,
                                      y: view.frame.height / 2 + 65)
        messageLabel.text = "You don't have decks yet."
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 20)
        messageLabel.textColor = .systemGray

        let button = UIButton().configureDefaultButton(title: "Create a deck")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCreateDeck), for: .touchUpInside)

        let emptyStateview = UIView()
        emptyStateview.addSubview(imageView)
        emptyStateview.addSubview(messageLabel)
        emptyStateview.addSubview(button)

        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.centerXAnchor.constraint(equalTo: emptyStateview.centerXAnchor).isActive = true
        button.safeTopAnchor.constraint(equalTo: emptyStateview.safeBottomAnchor, constant: -100).isActive = true

        tableView.backgroundView = emptyStateview
        tableView.isScrollEnabled = false
    }

    func restore() {
        tableView.backgroundView = nil
        tableView.isScrollEnabled = true
    }
}

extension DecksTableViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        do {
            let data = try CSV(url: url)
            for row in data.enumeratedColumns {
                print(row)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
