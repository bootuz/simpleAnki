import Foundation

enum ImportError: Error {
    case unzip(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
}

final class APKGManager {
    private var dbManager: APKGDatabase?
    private let destionation: URL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp")

    private let apkgURL: URL

    init(apkgURL: URL) {
        self.apkgURL = apkgURL

    }

    private func unzipApkg() throws {
        deleteTempFolderIfExists()
        do {
            try FileManager().unzipItem(at: apkgURL, to: destionation)
            try initializeDB()
        } catch {
            throw ImportError.unzip(message: "Could not unzip apkg file")
        }
    }

    private func initializeDB() throws {
        do {
            if FileManager().fileExists(atPath: destionation.appendingPathComponent("collection.anki21").path) {
                self.dbManager = try APKGDatabase(dbPath: destionation.appendingPathComponent("collection.anki21").path)
            } else {
                self.dbManager = try APKGDatabase(dbPath: destionation.appendingPathComponent("collection.anki2").path)
            }
        } catch {
            throw SQLiteError.openDatabase(message: "Could not initialize db")
        }

    }

    private func deleteTempFolderIfExists() {
        var isDir: ObjCBool = true
        if FileManager().fileExists(atPath: destionation.path, isDirectory: &isDir) {
            do {
                try FileManager().removeItem(atPath: destionation.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func prepareAPKGCards() throws -> [APKGCard] {
        do {
            try unzipApkg()
            try initializeDB()
            guard let apkgCards = try dbManager?.getCards() else {
                deleteTempFolderIfExists()
                throw ImportError.prepare(message: "Could not get cards")
            }
            return apkgCards
        } catch {
            deleteTempFolderIfExists()
            throw ImportError.prepare(message: "Could not get cards")
        }
    }
}
