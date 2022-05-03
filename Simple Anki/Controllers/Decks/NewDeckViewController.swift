//
//  NewDeckViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.04.2022.
//

import UIKit

class NewDeckViewController: UIViewController {
    
    var reloadData: (() -> Void)?
    
    private let deckView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let addCardsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add cards", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didCancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didSaveTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
        addCardsButton.isEnabled = false
        addCardsButton.backgroundColor = .systemGray2
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(deckView)
        view.addSubview(addCardsButton)
        deckView.addSubview(textField)
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        addCardsButton.addTarget(self, action: #selector(addCardsButtonTapped), for: .touchUpInside)
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
            addCardsButton.backgroundColor = .systemBlue
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            addCardsButton.isEnabled = false
            addCardsButton.backgroundColor = .systemGray2
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
