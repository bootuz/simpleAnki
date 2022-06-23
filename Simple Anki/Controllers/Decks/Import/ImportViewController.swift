//
//  ImportDeckViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 07.05.2022.
//

import UIKit
import UniformTypeIdentifiers
import SwiftCSV
import RealmSwift
import ZIPFoundation

enum ImportFileType: String {
    case csv
    case apkg
}

enum CSVDelimeterType: Character {
    case semiColon = ";"
    case comma = ","
    case tab = "\t"
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
    let importButton: UIButton = {
        let button = UIButton()
        button.configureDefaultButton(title: "Choose file...")
        return button
    }()
    let dontCloseAppLabel: UILabel = {
        let label = UILabel()
        label.text = "Importing deck. Please don't close the app!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGreen
        return label
    }()
    let apkgInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.textAlignment = .center
        let attrString = NSMutableAttributedString(string: "By now Simple Anki\nsupports only Front - Back layout.\nMake sure your apkg file contains those fields.")
        let attributes: [NSAttributedString.Key: Any] = [
            .font : UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
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
            .font : UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        ]
        attrString.addAttributes(attributes, range: NSRange(location: 35, length: 35))
        label.attributedText = attrString
        return label
    }()
    var selectedFile: ImportFileType = .apkg
    var selectedCSVDelimeter: CSVDelimeterType = .semiColon

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

    let stackView: UIStackView = {
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
        importButton.addTarget(self, action: #selector(didTapImportDeckButton), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)

        tabButton.addTarget(self, action: #selector(didTapTabButton), for: .touchUpInside)
        commaButton.addTarget(self, action: #selector(didTapCommaButton), for: .touchUpInside)
        semiColonButton.addTarget(self, action: #selector(didTapSemiColonButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)

        stackView.addArrangedSubview(semiColonButton)
        stackView.addArrangedSubview(commaButton)
        stackView.addArrangedSubview(tabButton)
        semiColonButton.isSelected = true
        semiColonButton.configuration?.baseForegroundColor = .white

        view.addSubview(stackView)
        view.addSubview(importButton)
        view.addSubview(apkgInfoLabel)
        view.addSubview(csvInfoLabel)
        view.addSubview(activityView)
        view.addSubview(dontCloseAppLabel)
        csvInfoLabel.isHidden = true
        stackView.isHidden = true
        dontCloseAppLabel.isHidden = true
    }

    @objc func didTapCloseButton() {
        dismiss(animated: true)
    }

    @objc func didTapSemiColonButton() {
        selectedCSVDelimeter = .semiColon
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
        stackView.frame.size = CGSize(width: 300, height: 50)
        stackView.center = view.center
        stackView.frame.origin.y += 25

        importButton.frame.size = CGSize(width: 300, height: 50)
        importButton.center = view.center
        importButton.frame.origin.y += 100

        csvInfoLabel.frame.size = CGSize(width: 300, height: 300)
        csvInfoLabel.center = view.center
        csvInfoLabel.frame.origin.y -= 80

        apkgInfoLabel.frame.size = CGSize(width: 300, height: 300)
        apkgInfoLabel.center = view.center
        apkgInfoLabel.frame.origin.y -= 50

        dontCloseAppLabel.frame.size = CGSize(width: 300, height: 300)
        dontCloseAppLabel.center = view.center
//        dontCloseAppLabel.frame.origin.y += 100

        activityView.center = view.center
        activityView.frame.origin.y -= 50

    }

    @objc private func didTapImportDeckButton() {
        presentDocumentPicker(with: selectedFile)
    }

    @objc private func didChangeSegmentedControl() {
        if segmentedControl.selectedSegmentIndex == 0 {
            selectedFile = .apkg
            stackView.isHidden = true
            csvInfoLabel.isHidden = true
            apkgInfoLabel.isHidden = false
        } else {
            selectedFile = .csv
            stackView.isHidden = false
            csvInfoLabel.isHidden = false
            apkgInfoLabel.isHidden = true
        }
    }

    func presentImportedCards(deckName: String, _ cards: [APKGCard]?) {
        guard let cards = cards else {
            // TODO: show error
            return
        }
        let importedCardsCV = ImportedCardsCollectionViewController()
        importedCardsCV.importedCards = cards
        importedCardsCV.deckName = deckName
        importedCardsCV.reloadData = reloadData
        let navVC = UINavigationController(rootViewController: importedCardsCV)
        navVC.modalPresentationStyle = .popover
        navVC.isModalInPresentation = true
        present(navVC, animated: true)
    }

    private func presentDocumentPicker(with type: ImportFileType) {
        guard let fileType = UTType(filenameExtension: type.rawValue) else { return }
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [fileType], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    func showActivityIndicator() {
        activityView.startAnimating()
        importButton.isHidden = true
        apkgInfoLabel.isHidden = true
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
        switch selectedFile {
        case .apkg:
            showActivityIndicator()
            var apkgCards: [APKGCard]?
            let apkgManager = APKGManager(apkgURL: url)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    apkgCards = try apkgManager.prepareAPKGCards()
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.presentImportedCards(deckName: url.lastPathComponent, apkgCards)
                }
            }
        case .csv:
            do {
                let csv = try CSV(url: url, delimiter: selectedCSVDelimeter.rawValue)
                print(csv)
                hideActivityIndicator()
            } catch {
                hideActivityIndicator()
                print(error)
            }
        }
    }
}
