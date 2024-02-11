//
//  SoundManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 29.08.2023.
//

import Foundation
import AVKit

class SoundManager {

    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    private var audioSession = AVAudioSession.sharedInstance()

    private init() {
        setupPlayer()
    }

    private func setupPlayer() {
        DispatchQueue.global(qos: .background).async {
            do {
                try self.audioSession.setCategory(.playAndRecord)
                try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func play(sound: String) {
        let url = FileManager.documentsDirectory.appendingPathComponent(sound)
        print(url)

        DispatchQueue.global(qos: .background).async {
            do {
                self.player = try AVAudioPlayer(contentsOf: url)
                self.player?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
                print("Error playing sound: \(error)")
            }
        }
    }

    func play(sound: URL) {
        DispatchQueue.global(qos: .background).async {
            do {
                self.player = try AVAudioPlayer(contentsOf: sound)
                self.player?.prepareToPlay()
                self.player?.play()
            } catch let error {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
}
