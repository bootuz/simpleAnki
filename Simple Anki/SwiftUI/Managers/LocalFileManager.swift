//
//  LocalFileManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 06.09.2023.
//

import Foundation

class LocalFileManager {

    static let shared = LocalFileManager()

    private init() { }

    func delete(_ fileName: String?) {
        guard let fileName = fileName else { return }
        do {
            try FileManager.default.removeItem(at: Self.documentsDirectory.appendingPathComponent(fileName))
        } catch {
            print(error)
        }
    }

    func delete(at path: URL?) {
        guard let path = path else { return }
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print(error)
        }
    }
}

extension LocalFileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func delete(_ fileName: String?) {

        guard let fileName = fileName else { return }
        let path = Self.documentsDirectory.appendingPathComponent(fileName)

        do {
            try Self.default.removeItem(at: path)
        } catch {
            print(error)
        }
    }

    func delete(at path: URL?) {

        guard let path = path else { return }

        do {
            try Self.default.removeItem(at: path)
        } catch {
            print(error)
        }
    }
}
