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

enum CSVDelimeterType: Character {
    case semiColon = ";"
    case comma = ","
    case tab = "\t"
}

class ImportViewController: UIViewController {
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["APKG", "CSV"])
        sc.selectedSegmentIndex = 0
        sc.setWidth(100, forSegmentAt: 0)
        sc.setWidth(100, forSegmentAt: 1)
        return sc
    }()
    let closeButton = UIButton(type: .close)
    let importButton = UIButton().configureDefaultButton(title: "Choose file...")
    let apkgInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "By now Simple Anki\nsupports only Front - Back layout.\nMake sure your apkg file contains those fields."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray2
        return label
    }()
    let csvInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "CSV file should contain two colums:\nFront1 : Back1\nFront2 : Back2.\nChoose delimeter below:"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray2
        return label
    }()
    var selectedFile: ImportFileType = .apkg
    var selectedCSVDelimeter: CSVDelimeterType = .semiColon
    
    var semiColonButton = UIButton().configureTintedButton(title: ";")
    var commaButton = UIButton().configureTintedButton(title: ",")
    var tabButton = UIButton().configureTintedButton(title: "\\t")
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.sizeToFit()
        stack.spacing = 20
        stack.axis = .horizontal
        return stack
    }()

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
        csvInfoLabel.isHidden = true
        stackView.isHidden = true
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
        if let cards = cards {
            let importedCardsCV = ImportedCardsCollectionViewController()
            importedCardsCV.importedCards = cards
            importedCardsCV.deckName = deckName
            let navVC = UINavigationController(rootViewController: importedCardsCV)
            navVC.modalPresentationStyle = .popover
            present(navVC, animated: true)
        } else {
            // show error
        }
        
    }
    
    private func presentDocumentPicker(with type: ImportFileType) {
        guard let csvType = UTType(filenameExtension: type.rawValue) else { return }
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [csvType], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
}

extension ImportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        switch selectedFile {
            case .apkg:
                let apkgManager = APKGManager(apkgURL: url)
                do {
                    try apkgManager.unzipApkg()
                    try apkgManager.initializeDB()
                    let apkgCards = try apkgManager.dbManager?.getCards()
                    apkgManager.deleteTempFolderIfExists()
                    presentImportedCards(deckName: url.lastPathComponent, apkgCards)
                } catch {
                    apkgManager.deleteTempFolderIfExists()
                    print(error)
                }
            case .csv:
                do {
                    let _ = try CSV(url: url, delimiter: selectedCSVDelimeter.rawValue)
                    print("test")
                } catch {
                    print(error)
                }
        }
    }
}
