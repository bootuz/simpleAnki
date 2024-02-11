//
//  ImportDeckView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 11.02.2024.
//

import SwiftUI
import SwiftCSV
import RealmSwift

struct ImportDeckView: View {
    @State private var deckName: String = ""
    @State private var errorMessage: String = ""
    @State private var parseError: Error?
    @State private var isAlertPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false
    @State private var isImportedCardsViewPresented: Bool = false
    @State private var selectedDelimeter: CSVDelimiter = .character("d")
    @State private var importedCards: RealmSwift.List<Card> = RealmSwift.List()

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            List {
                Section {
                    DelimeterButton(title: "Comma", delimeter: .comma, selectedDelimeter: $selectedDelimeter)
                    DelimeterButton(title: "Semicolon", delimeter: .semicolon, selectedDelimeter: $selectedDelimeter)
                    DelimeterButton(title: "Tab", delimeter: .tab, selectedDelimeter: $selectedDelimeter)
                } header: {
                    Text("Select delimeter")
                } footer: {
                    HStack(spacing: 3) {
                        Text("More information about")
                        Link("CSV files.", destination: URL(string: "https://en.wikipedia.org/wiki/Comma-separated_values")!)
                            .font(.footnote)
                    }
                }

                Section {
                    Button(action: {
                        isFileImporterPresented = true
                    }, label: {
                        Text("Choose file...")
                    })
                    .disabled(selectedDelimeter == .character("d"))
                    .fileImporter(
                        isPresented: $isFileImporterPresented,
                        allowedContentTypes: [.commaSeparatedText, .database],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let urls):
                            deckName = urls[0].lastPathComponent
                            do {
                                try parseCSV(from: urls[0])
                                isImportedCardsViewPresented = true
                            } catch {
                                isAlertPresented = true
                                errorMessage = "Could not parse the imported file."
                            }
                        case .failure(let failure):
                            isAlertPresented = true
                            errorMessage = failure.localizedDescription
                        }
                    }
                    .alert("Error", isPresented: $isAlertPresented, actions: {
                        Button("OK") { }
                    }, message: {
                        Text(errorMessage)
                    })
                    .sheet(isPresented: $isImportedCardsViewPresented) {
                        ImportedDeckView(deckName: $deckName, importedCards: $importedCards)
                    }
                }
            }
        }
    }

    private func parseCSV(from url: URL) throws {
        do {
            let csv = try EnumeratedCSV(url: url, delimiter: selectedDelimeter)
            for row in csv.rows {
                guard !row.isEmpty, row.count >= 2 else { continue }
                importedCards.append(Card(front: row[0], back: row[1]))
            }
        } catch {
            throw CSVParseError.generic(message: "Could not parse the csv file.")
        }
    }
}

#Preview {
    ImportDeckView()
}
