//
//  APKGModel.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 10.05.2022.
//

import Foundation

protocol Cards {
    var front: String { get set }
    var back: String { get set }
}

struct APKGCard: Cards {
    var front: String
    var back: String
}

struct CSVCard: Cards {
    var front: String
    var back: String
}

struct APKGModel: Codable {
    let id: Int
    var flds: [APKGField]

    func getFieldsName() -> [String] {
        return flds.map { fields in
            fields.name
        }
    }
}

struct APKGField: Codable {
    let name: String
    let ord: Int
}

extension APKGField: Comparable {
    static func < (lhs: APKGField, rhs: APKGField) -> Bool {
        return lhs.ord < rhs.ord
    }

    static func == (lhs: APKGField, rhs: APKGField) -> Bool {
        return lhs.ord == rhs.ord
    }
}
