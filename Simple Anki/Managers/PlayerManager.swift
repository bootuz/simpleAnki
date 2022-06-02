//
//  PlayerManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 05.06.2021.
//

import Foundation
import AVFoundation

class PlayerManager: NSObject, AVAudioPlayerDelegate {

    var audioPlayer : AVAudioPlayer!

    init(recordFilePath: URL) {
        super.init()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordFilePath)
            audioPlayer.delegate = self
        } catch {
            print("error: \(error)")
        }
    }

    func play(recordFilePath: URL) {
        audioPlayer.play()
    }
}
