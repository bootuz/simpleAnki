//
//  NewDeckViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.04.2022.
//

import UIKit
import SPIndicator

class NewDeckViewController: UIViewController {

    var reloadData: (() -> Void)?
    let indicatorView = SPIndicatorView(title: "Deck saved", preset: .done)
    private let deckView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()

    private let addCardsButton = UIButton().configureDefaultButton(
        title: "Add cards",
        image: UIImage(systemName: "arrow.forward")
    )

    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        field.font = .systemFont(ofSize: 26, weight: .bold)
        field.returnKeyType = .next
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New deck"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didCancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didSaveTapped)
        )
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        addCardsButton.addTarget(self, action: #selector(addCardsButtonTapped), for: .touchUpInside)
        setupUI()

    }

    private func setupUI() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        addCardsButton.isEnabled = false
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(deckView)
        view.addSubview(addCardsButton)
        deckView.addSubview(textField)
        textField.becomeFirstResponder()

        let leftPadding = 16.0
        let rightPadding = 32.0

        deckView.frame = CGRect(x: leftPadding,
                                y: 200.0,
                                width: view.bounds.width - rightPadding,
                                height: 80.0)
        textField.frame = CGRect(x: leftPadding,
                                 y: (deckView.frame.height - 40.0) / 2.0,
                                 width: deckView.frame.width - rightPadding,
                                 height: 40.0)

        addCardsButton.translatesAutoresizingMaskIntoConstraints = false
        addCardsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        addCardsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        addCardsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addCardsButton.safeBottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).isActive = true
    }

    @objc func didCancelTapped() {
        dismiss(animated: true)
    }

    @objc func didSaveTapped() {
        let newDeck = Deck()
        guard let deckName = textField.text else { return }
        newDeck.name = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
        StorageManager.save(newDeck)
        reloadData?()
        indicatorView.present(duration: 0.5, haptic: .success)
        dismiss(animated: true)
    }

    @objc func addCardsButtonTapped() {
        let newCardVC = NewCardViewController()
        let newDeck = Deck()
        guard let deckName = textField.text else { return }
        newDeck.name = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
        StorageManager.save(newDeck)
        newCardVC.selectedDeck = newDeck
        addCardsButton.isHidden = true
        textField.resignFirstResponder()
        navigationController?.pushViewController(newCardVC, animated: true)
    }


    @objc func textFieldChanged() {
        if textField.text?.isEmpty == false {
            navigationItem.rightBarButtonItem?.isEnabled = true
            addCardsButton.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            addCardsButton.isEnabled = false
        }
    }

}
