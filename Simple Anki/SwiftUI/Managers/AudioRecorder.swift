//
//  RecorderManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.09.2023.
//

import Foundation
import AVFoundation

@Observable
class AudioRecorder: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var isPlaybackReady = false
    var isRecording = false

    @ObservationIgnored
    private var audioRecorder: AVAudioRecorder?
    @ObservationIgnored
    private var player: AVAudioPlayer?
    @ObservationIgnored
    private var fileName: String
    @ObservationIgnored
    private var audioSession = AVAudioSession.sharedInstance()

    init(fileName: String) {
        self.fileName = fileName
        super.init()
    }

    private let settings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2
    ]

    func startRecording() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let fileURL = FileManager.documentsDirectory.appendingPathComponent(fileName)

            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Error setting up audio recorder: \(error.localizedDescription)")
        }
    }

    func stopRecording(completion: @escaping (String) -> Void) {
        audioRecorder?.stop()

        isRecording = false
        isPlaybackReady = true
        completion(fileName)
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            isPlaybackReady = true
        }
    }

    func checkRecordPermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
                AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }

    func deleteRecording() {
        let url = FileManager.documentsDirectory.appendingPathComponent(fileName)

        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }

    func setName(_ name: String) {
        fileName = name
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
}
