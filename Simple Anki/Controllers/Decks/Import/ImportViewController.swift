//
//  ImportDeckViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 07.05.2022.
//

import UIKit
import UniformTypeIdentifiers

enum ImportFileType: String {
    case csv
    case apkg
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
    
    let importButton = UIButton().configureDefaultButton(title: "Import deck")
    
    let apkgInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "By now Simple Anki\nsupports only front - back layout.\nMake sure your apkg file contains\n those fields."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray2
        return label
    }()
    
    var selectedFileType: ImportFileType = .apkg
    var apkgManager: APKGManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.titleView = segmentedControl
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        importButton.addTarget(self, action: #selector(didTapImportDeckButton), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControl), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        view.addSubview(importButton)
        view.addSubview(apkgInfoLabel)
    }
    
    @objc func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        importButton.frame.size = CGSize(width: 300, height: 50)
        importButton.center = view.center
        importButton.frame.origin.y += 100
        
        apkgInfoLabel.frame.size = CGSize(width: 300, height: 300)
        apkgInfoLabel.center = view.center
        apkgInfoLabel.frame.origin.y -= 50
    }
    
    @objc private func didTapImportDeckButton() {
        presentDocumentPicker(with: selectedFileType)
//        testPresent()
    }
    
    @objc private func didChangeSegmentedControl() {
        if segmentedControl.selectedSegmentIndex == 0 {
            selectedFileType = .apkg
        } else {
            selectedFileType = .csv
        }
    }
    
    func testPresent(with cards: [APKGCard]) {
        let importedCardsCV = ImportedCardsCollectionViewController()
        importedCardsCV.importedCards = cards
        let navVC = UINavigationController(rootViewController: importedCardsCV)
        navVC.modalPresentationStyle = .popover
        present(navVC, animated: true)
    }
    
    private func presentDocumentPicker(with type: ImportFileType) {
        let csvType = UTType(filenameExtension: type.rawValue)!
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [csvType], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
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

extension ImportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        print(url)
        apkgManager = APKGManager(apkgURL: url)
        do {
            try apkgManager?.unzipApkg()
            try apkgManager?.initializeDB()
            let apkgCards = try apkgManager?.dbManager?.getCards()
            guard let cards = apkgCards else {
                // show error
                return
            }
            testPresent(with: cards)
        } catch {
            print(error)
        }
        
        
        
    }
}
