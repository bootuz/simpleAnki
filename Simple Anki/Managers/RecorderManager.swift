//
//  AudioManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 22.05.2021.
//

import Foundation
import AVFoundation

class RecorderManager: NSObject, AVAudioRecorderDelegate {
    static let shared = RecorderManager()

    private override init() { }
}
