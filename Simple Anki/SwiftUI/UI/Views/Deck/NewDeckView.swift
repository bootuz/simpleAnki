//
//  NewDeckView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 10.02.2024.
//

import SwiftUI
import RealmSwift
import SwiftCSV

enum Delimeter: String {
    case comma = ","
    case semicolon = ";"
    case tab = "\t"
    case none = ""
}

struct NewDeckView: View {
    @ObservedResults(Deck.self, sortDescriptor: SortDescriptor(keyPath: "dateCreated", ascending: false)) var decks
    @State private var deckName: String = ""
    @State private var selectedSegment: Int = 0
    @State private var isFileImporterPresented: Bool = false
    @State private var isImportedCardsViewPresented: Bool = false
    @State private var selectedDelimeter: CSVDelimiter = .character("d")
    @State private var importedCards: RealmSwift.List<Card> = RealmSwift.List()

    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm

    var body: some View {
        NavigationStack {
            ZStack {
                if selectedSegment == 0 {
                    CreateDeckView()
                } else {
                    ImportDeckView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("test", selection: $selectedSegment) {
                        Text("Create").tag(0)
                        Text("Import").tag(1)
                    }
                    .frame(width: 200)
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    @ViewBuilder
    private func ImportDeckView() -> some View {
        VStack {
            List {
                Section {
                    DelimeterButton(title: "Comma", delimeter: .comma)
                    DelimeterButton(title: "Semicolon", delimeter: .semicolon)
                    DelimeterButton(title: "Tab", delimeter: .tab)
                } header: {
                    Text("Select delimeter")
                } footer: {
                    HStack(spacing: 3) {
                        Text("More information about")
                        Link("CSV files.", destination: URL(string: "https://en.wikipedia.org/wiki/Comma-separated_values")!)
                            .font(.caption2)
                    }
                }

                Section {
                    Button(action: {
                        isFileImporterPresented = true
                    }, label: {
                        Text("Choose file...")
                    })
                    .disabled(selectedDelimeter == .character("d"))
                    .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.commaSeparatedText], allowsMultipleSelection: false) { result in
                        switch result {
                        case .success(let success):
                            print(success)
                            deckName = success[0].lastPathComponent
                            do {
                                let csv = try CSV<Enumerated>(url: success[0], delimiter: selectedDelimeter)
                                for row in csv.rows {
                                    guard !row.isEmpty, row.count >= 2 else { continue }
//                                    let front = self.cleanString(row[0])
//                                    let back = self.cleanString(row[1])
                                    importedCards.append(Card(front: row[0], back: row[1]))
//                                    dismiss()
                                    isImportedCardsViewPresented = true
                                }
                            } catch {
//                                self.showAlert(with: "Error", message: "Could not import deck")
                                print(error)
                            }
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                    .sheet(isPresented: $isImportedCardsViewPresented) {
                        NavigationStack {
                            List {
                                Section("Edit name") {
                                    TextField("Deck name", text: $deckName)
                                }
                                Section("Cards") {
                                    ForEach(importedCards) { card in
                                        Button(action: {

                                        }, label: {
                                            Text("\(card.front) - \(card.back)")
                                        })
                                    }
                                    .onDelete(perform: { indexSet in
                                        importedCards.remove(atOffsets: indexSet)
                                    })
                                }
                            }
                            .navigationTitle("Imported deck")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button(action: {
                                        var deck = Deck(name: deckName)
                                        deck.cards = importedCards
                                        $decks.append(deck)
                                        dismiss()
                                    }, label: {
                                        Text("Done")
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func DelimeterButton(title: String, delimeter: CSVDelimiter) -> some View {
        Button(action: {
            selectedDelimeter = delimeter
        }, label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
                    .opacity(selectedDelimeter == delimeter ? 1: 0)
            }
        })
        .tint(.primary)
    }
}

#Preview {
    NewDeckView()
}
