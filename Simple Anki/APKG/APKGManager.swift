import Foundation

enum ZIPError: Error {
    case Unzip(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

final class APKGManager {
    var dbManager: APKGDatabase?
    let destionation: URL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp")
    
    let apkgURL: URL
    
    init(apkgURL: URL) {
        self.apkgURL = apkgURL
        
    }
    
    func unzipApkg() throws {
        deleteTempFolderIfExists()
        do {
            try FileManager().unzipItem(at: apkgURL, to: destionation)
            try initializeDB()
        } catch {
            throw ZIPError.Unzip(message: "Could not unzip apkg file")
        }
    }
    
    func initializeDB() throws {
        do {
            if FileManager().fileExists(atPath: destionation.appendingPathComponent("collection.anki21").path) {
                self.dbManager = try APKGDatabase(dbPath: destionation.appendingPathComponent("collection.anki21").path)
            } else {
                self.dbManager = try APKGDatabase(dbPath: destionation.appendingPathComponent("collection.anki2").path)
            }
        } catch {
            throw SQLiteError.OpenDatabase(message: "Could not initialize db")
        }
        
    }
    
    func deleteTempFolderIfExists() {
        var isDir: ObjCBool = true
        if FileManager().fileExists(atPath: destionation.path, isDirectory: &isDir) {
            do {
                try FileManager().removeItem(atPath: destionation.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
