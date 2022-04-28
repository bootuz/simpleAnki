//
//  URLExtention.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 05.06.2021.
//

import Foundation

extension URL {
    func exists() -> Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
}

