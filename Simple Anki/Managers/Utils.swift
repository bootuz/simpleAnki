//
//  Utils.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 04.06.2021.
//

import Foundation

class Utils {
    
    private static let fileManager = FileManager.default
    
    static func generateNewRecordName() -> URL {
        return getAudioFilePath(with: "\(UUID().uuidString).m4a")
    }
    
    static func getDocumentsDirectory() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func getAudioFilePath(with name: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(name)
    }
    
    static func deleteAudioFile(with name: String) {
        let audioFilePath = getAudioFilePath(with: name)
        if audioFilePath.exists() {
            do {
                try fileManager.removeItem(at: audioFilePath)
            } catch {
                print("Could not delete file: \(error)")
            }
            
        }
    }
    
    static func deleteAudioFile(at path: URL) {
        if path.exists() {
            do {
                try fileManager.removeItem(at: path)
            } catch {
                print("Could not delete file: \(error)")
            }
            
        }
    }
}
