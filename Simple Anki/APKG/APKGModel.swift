//
//  APKGModel.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 10.05.2022.
//

import Foundation

struct APKGCard {
    let front: String
    let back: String
}

typealias CSVCard = APKGCard

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
