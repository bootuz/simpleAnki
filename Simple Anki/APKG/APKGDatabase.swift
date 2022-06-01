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
  case OpenDatabase(message: String)
  case Prepare(message: String)
  case Step(message: String)
  case Bind(message: String)
}

struct Queries {
    static let notes = Table("notes")
    static let col = Table("col")
    static let models = Expression<String>("models")
    static let flds = Expression<String>("flds")
    static let mid = Expression<Int64>("mid")
}

class APKGDatabase {
    var db: Connection?
    
    init(dbPath: String) throws {
        do {
            self.db = try Connection(dbPath)
        } catch {
            print(error)
            throw SQLiteError.OpenDatabase(message: "Could not initilize database")
        }
    }
    
    private func fetch(table: Table) -> RowIterator? {
        do {
            let rowIterator = try db?.prepareRowIterator(table)
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
            guard let rowIterator = fetch(table: Queries.notes) else {
                throw SQLiteError.Prepare(message: "Could not get data from table")
            }
            while let row = try rowIterator.failableNext() {
                guard var fields = getFields() else { return [] }
                fields.sort(by: <)
                let headers = fields.map({ $0.name })
                let data = fetch(col: Queries.flds, row: row)
                let cleanedData = data.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    .replacingOccurrences(of: "[\\[].*?[\\]]", with: "", options: .regularExpression, range: nil).components(separatedBy: "\u{1F}")
                let result = Dictionary(uniqueKeysWithValues: zip(headers, cleanedData))
                guard let front = result["Front"],
                      let back = result["Back"]
                else { break }
                cards.append(APKGCard(front: front, back: back))
            }
            return cards
        } catch {
            throw SQLiteError.Prepare(message: error.localizedDescription)
        }
    }
}

