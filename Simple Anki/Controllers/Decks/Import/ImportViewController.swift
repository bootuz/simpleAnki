//
//  ImportDeckViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 07.05.2022.
//

import UIKit
import UniformTypeIdentifiers
import SwiftCSV

enum ImportFileType: String {
    case csv
    case apkg
}

class ImportViewController: UIViewController {

    let activityView = UIActivityIndicatorView(style: .medium)
    let segmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["APKG", "CSV"])
        segmentControl.selectedSegmentIndex = 0
        for index in 0..<segmentControl.numberOfSegments {
            segmentControl.setWidth(100, forSegmentAt: index)
        }
        return segmentControl
    }()
    let closeButton = UIButton(type: .close)
    let chooseFileButton: UIButton = {
        let button = UIButton()
        button.configureDefaultButton(title: "Choose file...")
        return button
    }()
    let importingDeckLabel: UILabel = {
        let label = UILabel()
        label.text = "Importing deck..."
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    let dontCloseAppLabel: UILabel = {
        let label = UILabel()
        label.text = "Please don't close the app."
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    let apkgInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.textAlignment = .center
        let attrString = NSMutableAttributedString(string: "By now Simple Anki\nsupports only Front - Back layout.\nMake sure your apkg file contains those fields.")
        let attributes: [NSAttributedString.Key: Any] = [
            .font : UIFont.boldSystemFont(ofSize: 17)
        ]
        attrString.addAttributes(attributes, range: NSRange(location: 32, length: 13))
        label.attributedText = attrString
        return label
    }()
    let csvInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.textAlignment = .center
        let attrString = NSMutableAttributedString(string: "CSV file should contain two colums:\nFront1 : Back1\nFront2 : Back2\n...\nChoose delimeter below:")
        let attributes: [NSAttributedString.Key: Any] = [
            .font : UIFont.boldSystemFont(ofSize: 17)
        ]
        attrString.addAttributes(attributes, range: NSRange(location: 35, length: 35))
        label.attributedText = attrString
        return label
    }()
    var selectedFile: ImportFileType = .apkg
    var selectedCSVDelimeter: CSVDelimiter = .semicolon

    var semiColonButton: UIButton = {
        let button = UIButton()
        button.configureTintedButton(title: ";")
        return button
    }()

    var commaButton: UIButton = {
        let button = UIButton()
        button.configureTintedButton(title: ",")
        return button
    }()

    var tabButton: UIButton = {
        let button = UIButton()
        button.configureTintedButton(title: "\\t")
        return button
    }()

    let delimeterStackView: UIStackView = {
        let stack = UIStackView()
        stack.sizeToFit()
        stack.spacing = 20
        stack.axis = .horizontal
        return stack
    }()

    var reloadData: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.titleView = segmentedControl
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        chooseFileButton.addTarget(self, action: #selector(didTapChooseFileButton), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)

        tabButton.addTarget(self, action: #selector(didTapTabButton), for: .touchUpInside)
        commaButton.addTarget(self, action: #selector(didTapCommaButton), for: .touchUpInside)
        semiColonButton.addTarget(self, action: #selector(didTapSemiColonButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)

        delimeterStackView.addArrangedSubview(semiColonButton)
        delimeterStackView.addArrangedSubview(commaButton)
        delimeterStackView.addArrangedSubview(tabButton)
        semiColonButton.isSelected = true
        semiColonButton.configuration?.baseForegroundColor = .white

        view.addSubview(delimeterStackView)
        view.addSubview(chooseFileButton)
        view.addSubview(apkgInfoLabel)
        view.addSubview(csvInfoLabel)
        view.addSubview(activityView)
        view.addSubview(importingDeckLabel)
        view.addSubview(dontCloseAppLabel)
        csvInfoLabel.isHidden = true
        delimeterStackView.isHidden = true
        importingDeckLabel.isHidden = true
        dontCloseAppLabel.isHidden = true
    }

    @objc func didTapCloseButton() {
        dismiss(animated: true)
    }

    @objc func didTapSemiColonButton() {
        selectedCSVDelimeter = .semicolon
        semiColonButton.isSelected = true
        commaButton.isSelected = false
        tabButton.isSelected = false
        tabButton.configuration?.baseForegroundColor = .systemBlue
        commaButton.configuration?.baseForegroundColor = .systemBlue
        semiColonButton.configuration?.baseForegroundColor = .white
    }

    @objc func didTapCommaButton() {
        selectedCSVDelimeter = .comma
        semiColonButton.isSelected = false
        commaButton.isSelected = true
        tabButton.isSelected = false
        tabButton.configuration?.baseForegroundColor = .systemBlue
        commaButton.configuration?.baseForegroundColor = .white
        semiColonButton.configuration?.baseForegroundColor = .systemBlue
    }

    @objc func didTapTabButton() {
        selectedCSVDelimeter = .tab
        semiColonButton.isSelected = false
        commaButton.isSelected = false
        tabButton.isSelected = true
        tabButton.configuration?.baseForegroundColor = .white
        commaButton.configuration?.baseForegroundColor = .systemBlue
        semiColonButton.configuration?.baseForegroundColor = .systemBlue
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        delimeterStackView.frame.size = CGSize(width: 300, height: 50)
        delimeterStackView.center = view.center
        delimeterStackView.frame.origin.y += 25

        chooseFileButton.frame.size = CGSize(width: 300, height: 50)
        chooseFileButton.center = view.center
        chooseFileButton.frame.origin.y += 100

        csvInfoLabel.frame.size = CGSize(width: 300, height: 300)
        csvInfoLabel.center = view.center
        csvInfoLabel.frame.origin.y -= 80

        apkgInfoLabel.frame.size = CGSize(width: 300, height: 300)
        apkgInfoLabel.center = view.center
        apkgInfoLabel.frame.origin.y -= 50

        dontCloseAppLabel.translatesAutoresizingMaskIntoConstraints = false
        importingDeckLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            importingDeckLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 190),
            importingDeckLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            importingDeckLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),

            dontCloseAppLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 220),
            dontCloseAppLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            dontCloseAppLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40)
        ])

        activityView.center = view.center
        activityView.frame.origin.y -= 50

    }

    @objc private func didTapChooseFileButton() {
        self.presentDocumentPicker()
    }

    @objc private func didChangeSegmentedControl() {
        if segmentedControl.selectedSegmentIndex == 0 {
            selectedFile = .apkg
            delimeterStackView.isHidden = true
            csvInfoLabel.isHidden = true
            apkgInfoLabel.isHidden = false
        } else {
            selectedFile = .csv
            delimeterStackView.isHidden = false
            csvInfoLabel.isHidden = false
            apkgInfoLabel.isHidden = true
        }
    }

    func presentImportedCards(deckName: String, _ cards: [Cards]) {
        let importedCardsCV = ImportedCardsCollectionViewController()
        importedCardsCV.importedCards = cards
        importedCardsCV.deckName = deckName
        importedCardsCV.reloadData = reloadData
        let navVC = UINavigationController(rootViewController: importedCardsCV)
        navVC.modalPresentationStyle = .popover
        navVC.isModalInPresentation = true
        present(navVC, animated: true)
    }

    private func presentDocumentPicker() {
        guard let fileType = UTType(filenameExtension: selectedFile.rawValue) else { return }
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [fileType], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    func showActivityIndicator() {
        activityView.startAnimating()
        chooseFileButton.isHidden = true
        apkgInfoLabel.isHidden = true
        csvInfoLabel.isHidden = true
        delimeterStackView.isHidden = true
        importingDeckLabel.isHidden = false
        dontCloseAppLabel.isHidden = false
    }

    func hideActivityIndicator() {
        if activityView.isAnimating {
            activityView.stopAnimating()
        }
    }
}

extension ImportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        showActivityIndicator()
        switch selectedFile {
        case .apkg:
            var apkgCards: [Cards] = []
            let apkgManager = APKGManager(apkgURL: url)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    apkgCards = try apkgManager.prepareAPKGCards()
                } catch {
                    self.showAlert(with: "Error", message: "Could not import deck")
                    print(error)
                }
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.presentImportedCards(deckName: url.lastPathComponent, apkgCards)
                }
            }
        case .csv:
            var csvCards: [Cards] = []
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let csv = try CSV<Enumerated>(url: url, delimiter: self.selectedCSVDelimeter)
                    for row in csv.rows {
                        guard !row.isEmpty, row.count >= 2 else { continue }
                        let front = self.cleanString(row[0])
                        let back = self.cleanString(row[1])
                        csvCards.append(CSVCard(front: front, back: back))
                    }
                } catch {
                    self.showAlert(with: "Error", message: "Could not import deck")
                    print(error)
                }
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.presentImportedCards(deckName: url.lastPathComponent, csvCards)
                }
            }
        }
    }

    private func showAlert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
      }

    private func cleanString(_ data: String) -> String {
        return data.replaceOccurrences(of: "<[^>]+>", with: "").replaceOccurrences(of: "[\\[].*?[\\]]", with: "")
    }
}

extension String {
    func replaceOccurrences(of this: String, with that: String) -> String {
        return self.replacingOccurrences(of: this, with: that, options: .regularExpression, range: nil)
    }
}
