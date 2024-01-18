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

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }

    func play(sound: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullUrl = documentDirectory.appendingPathComponent(sound)

        do {
            self.player = try AVAudioPlayer(contentsOf: fullUrl)
            self.player?.prepareToPlay()
            self.player?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
            print("Error playing sound: \(error)")
        }
    }

    func play(sound: URL) {
        do {
            self.player = try AVAudioPlayer(contentsOf: sound)
            self.player?.prepareToPlay()
            self.player?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
