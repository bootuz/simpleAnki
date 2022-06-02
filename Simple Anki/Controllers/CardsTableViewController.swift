//
//  CardsTableViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 28.02.2021.
//

import UIKit
import RealmSwift

class CardsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: K.cardCellIdentifier)
        return table
    }()

    private lazy var cardToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = .systemBackground
        return toolbar
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl (items: ["Learning", "Memorized"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    var cards: Results<Card>?
    var cardsToDisplay: Results<Card>?

    var selectedDeck: Deck? {
        didSet {
            loadCards()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = selectedDeck?.name
        view.addSubview(tableView)
        tableView.frame = view.bounds
        segmentedControl.addTarget(self, action: #selector(segmentedControlSwitched), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapPlus)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        configureToolbar()
        tableView.contentInset.bottom = cardToolbar.constraints[1].constant
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCards()
    }

    //  MARK: - Private methods

    private func configureToolbar() {
        let gearButton = UIButton().configureIconButton(
            configuration: .tinted(),
            image: UIImage(systemName: "gearshape")
        )
        gearButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        gearButton.addTarget(self, action: #selector(didLayoutTap), for: .touchUpInside)
        let gear = UIBarButtonItem(customView: gearButton)

        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let reviewButton = UIButton().configureDefaultButton(title: "Review")
        reviewButton.frame = CGRect(x: 0, y: 0, width: view.frame.width - 98, height: 50)
        reviewButton.addTarget(self, action: #selector(reviewButtonTouchUpInside), for: .touchUpInside)
        let review = UIBarButtonItem(customView: reviewButton)

        cardToolbar.items = [gear, flexible, review]
        view.addSubview(cardToolbar)
        cardToolbar.translatesAutoresizingMaskIntoConstraints = false
        cardToolbar.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        cardToolbar.heightAnchor.constraint(equalToConstant: 70).isActive = true
        cardToolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16).isActive = true

    }

    // MARK: - Actions

    @objc private func segmentedControlSwitched() {
        print(segmentedControl.selectedSegmentIndex)
        if segmentedControl.selectedSegmentIndex == 0 {
            cardsToDisplay = cards?.where({ $0.memorized == false })
        } else {
            cardsToDisplay = cards?.where({ $0.memorized == true })
        }
        reload()
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func reviewButtonTouchUpInside() {
        let reviewVC = ReviewViewController()
        guard let deck = selectedDeck else { return }
        guard let cardsToReview = cards?.where({ $0.memorized == false }) else { return }
        reviewVC.reviewManager = ReviewManager(layout: deck.layout,
                                               autoPlay: deck.autoplay,
                                               cards: cardsToReview.shuffled())
        let navVC = UINavigationController(rootViewController: reviewVC)
        navVC.view.backgroundColor = UIColor.systemBackground
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }

    @objc private func didLayoutTap() {
        let alert = UIAlertController(title: "Set layout", message: nil, preferredStyle: .actionSheet)
        let frontToBack = UIAlertAction(title: "Front-to-Back", style: .default) { (action) in
            try! StorageManager.realm.write {
                self.selectedDeck?.layout = K.Layout.frontToBack
            }
            self.tableView.reloadData()
        }

        let backToFront = UIAlertAction(title: "Back-to-Front", style: .default) { (action) in
            try! StorageManager.realm.write {
                self.selectedDeck?.layout = K.Layout.backToFront
            }
            self.tableView.reloadData()
        }

        let all = UIAlertAction(title: "All", style: .default) { (action) in
            try! StorageManager.realm.write {
                self.selectedDeck?.layout = K.Layout.all
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        let checked = "checked"
        switch selectedDeck?.layout {
        case K.Layout.frontToBack:
            frontToBack.setValue(true, forKey: checked)
            backToFront.setValue(false, forKey: checked)
            all.setValue(false, forKey: checked)
        case K.Layout.backToFront:
            frontToBack.setValue(false, forKey: checked)
            backToFront.setValue(true, forKey: checked)
            all.setValue(false, forKey: checked)
        case K.Layout.all:
            frontToBack.setValue(false, forKey: checked)
            backToFront.setValue(false, forKey: checked)
            all.setValue(true, forKey: checked)
        default:
            break
        }

        alert.addAction(frontToBack)
        alert.addAction(backToFront)
        alert.addAction(all)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    @objc private func didTapPlus() {
        let newCardVC = NewCardViewController()
        let navVC = UINavigationController(rootViewController: newCardVC)
        navVC.modalPresentationStyle = .fullScreen
        newCardVC.selectedDeck = selectedDeck
        present(navVC, animated: true)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cardsCount = cardsToDisplay?.count {
            if segmentedControl.selectedSegmentIndex == 0 {
                if cardsCount == 0 {
                    setEmptyState()
                    cardToolbar.isHidden = true
                } else {
                    restore()
                    cardToolbar.isHidden = false
                }
            } else {
                if cardsCount == 0 {
                    setEmptyStateForMemorizedCards()
                    cardToolbar.isHidden = true
                } else {
                    restore()
                    cardToolbar.isHidden = true
                }
            }
        }
        return cardsToDisplay?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cardCellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.lineBreakMode = .byTruncatingTail
        content.textProperties.numberOfLines = 1
        content.secondaryTextProperties.lineBreakMode = .byTruncatingTail
        content.secondaryTextProperties.numberOfLines = 1
        content.text = cardsToDisplay?[indexPath.row].front
        content.secondaryText = cardsToDisplay?[indexPath.row].back
        cell.contentConfiguration = content
        return cell
    }


    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [makeCardMemorizedContextualAction(forRowAt: indexPath)])
        return config
    }

    private func makeCardMemorizedContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let memorizedContextualAction = UIContextualAction(style: .normal, title: "Memorized") { (action, swipeButtonView, completion) in
            guard let cards = self.cardsToDisplay else { return }
            let card = cards[indexPath.row]
            try! StorageManager.realm.write {
                if card.memorized == false {
                    card.memorized = true
                } else {
                    card.memorized = false
                }
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        memorizedContextualAction.image = UIImage(systemName: "brain")
        memorizedContextualAction.backgroundColor = .systemGreen
        return memorizedContextualAction
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [makeDeleteContextualAction(forRowAt: indexPath)])
    }

    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let deleteContextualAction = UIContextualAction(style: .destructive, title: "Delete") { (action, swipeButtonView, completion) in
            guard let cards = self.cardsToDisplay else { return }
            let card = cards[indexPath.row]
            StorageManager.delete(card)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteContextualAction.image = UIImage(systemName: "trash")
        return deleteContextualAction
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newCardVC = NewCardViewController()
        let navVC = UINavigationController(rootViewController: newCardVC)
        newCardVC.selectedCard = cardsToDisplay?[indexPath.row]
        newCardVC.selectedDeck = selectedDeck
        newCardVC.reloadData = { [weak self] in
            self?.reload()
        }
        present(navVC, animated: true)
    }

    func loadCards() {
        cards = selectedDeck?.cards.sorted(byKeyPath: "dateCreated", ascending: true)
        if segmentedControl.selectedSegmentIndex == 0 {
            cardsToDisplay = cards?.where({ $0.memorized == false })
        } else {
            cardsToDisplay = cards?.where({ $0.memorized == true })
        }
        reload()
    }
}

extension CardsTableViewController: RefreshDataDelegate {
    func reload() {
        tableView.reloadData()
    }
}

extension CardsTableViewController: EmptyStateDelegate {
    func setEmptyStateForMemorizedCards() {
        let imageView = UIImageView(image: UIImage(systemName: "brain"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFill

        let messageLabel = UILabel()
        messageLabel.text = "No memorized cards in this deck."
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 20)
        messageLabel.textColor = .systemGray

        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel])
        stackView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        stackView.spacing = 20
        stackView.center = view.center
        stackView.axis = .vertical
        stackView.alignment = .center

        let emptyStateview = UIView()
        emptyStateview.addSubview(stackView)
        tableView.backgroundView = emptyStateview
        tableView.isScrollEnabled = false
    }

    func setEmptyState() {
        let imageView = UIImageView(image: UIImage(systemName: "square.stack"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray3

        let messageLabel = UILabel()
        messageLabel.text = "No cards in this deck."
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 20)
        messageLabel.textColor = .systemGray

        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel])
        stackView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        stackView.spacing = 20
        stackView.center = view.center
        stackView.axis = .vertical
        stackView.alignment = .center

        let button = UIButton().configureDefaultButton(title: "Add a card")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)

        let emptyStateview = UIView()
        emptyStateview.addSubview(stackView)
        emptyStateview.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
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

