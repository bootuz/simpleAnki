//
//  APKGDatabase.swift
//
//
//  Created by Астемир Бозиев on 06.05.2022.
//

import Foundation
import ZIPFoundation
import SQLite

enum SQLiteError: Error {
    case openDatabase(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
}

struct Queries {
    static let notes = Table("notes")
    static let col = Table("col")
    static let models = Expression<String>("models")
    static let flds = Expression<String>("flds")
    static let mid = Expression<Int64>("mid")
}

class APKGDatabase {
    var dbConn: Connection?

    init(dbPath: String) throws {
        do {
            self.dbConn = try Connection(dbPath)
        } catch {
            print(error)
            throw SQLiteError.openDatabase(message: "Could not initilize database")
        }
    }

    private func fetch(table: Table) -> RowIterator? {
        do {
            let rowIterator = try dbConn?.prepareRowIterator(table)
            return rowIterator
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    private func fetch<T: Value>(col: Expression<T>, row: Row) -> T {
        return row[col]
    }

    func getFields() -> [APKGField]? {
        guard let row = fetch(table: Queries.col)?.next() else { return nil }
        let data = fetch(col: Queries.models, row: row)
        let model: [String: APKGModel]? = decode(data: data)
        return model?.values.first?.flds
    }

    private func decode<T>(data: String?) -> [String: T]? where T: Codable {
        guard let data = data?.data(using: .utf8) else { return nil }
        do {
            let result = try JSONDecoder().decode([String: T].self, from: data)
            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getCards() throws -> [APKGCard] {
        var cards = [APKGCard]()
        do {
            guard let rowIterator = fetch(table: Queries.notes),
                  var fields = getFields()
            else {
                throw SQLiteError.prepare(message: "Could not get data apkg")
            }
            fields.sort(by: <)
            let headers = fields.map { $0.name }
            while let row = try rowIterator.failableNext() {
                let data = fetch(col: Queries.flds, row: row)
                let cleanedData = data
                    .replaceOccurrences(of: "<[^>]+>", with: "")
                    .replaceOccurrences(of: "[\\[].*?[\\]]", with: "")
                    .components(separatedBy: "\u{1F}")
                let result = Dictionary(uniqueKeysWithValues: zip(headers, cleanedData))
                guard let front = result["Front"],
                        let back = result["Back"]
                else { break }
                cards.append(APKGCard(front: front, back: back))
            }
            return cards
        } catch {
            throw SQLiteError.prepare(message: error.localizedDescription)
        }
    }
}
