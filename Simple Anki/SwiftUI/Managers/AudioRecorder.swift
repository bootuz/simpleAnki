//
//  RecorderManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.09.2023.
//

import Foundation
import AVFoundation

class AudioRecorder: ObservableObject {
    private var audioRecorder: AVAudioRecorder?

    @Published var isRecording = false
    @Published var audioURL: URL?
    private var audioName: String?

    private var settings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2
    ]

    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            guard let audioName = audioName else { return }
            let audioFileURL = documentsDirectory.appendingPathComponent("\(audioName).m4a")

            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        self.setupAudioRecorder()
        guard let audioRecorder = audioRecorder else { return }

        if !audioRecorder.isRecording {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                audioRecorder.record()
                isRecording = true
            } catch {
                print("Error starting recording: \(error.localizedDescription)")
            }
        }
    }

    func stopRecording() {
        if let audioRecorder = audioRecorder, audioRecorder.isRecording {
            audioRecorder.stop()
            isRecording = false
            audioURL = audioRecorder.url
        }
    }

    func isMicAccessGranted() -> Bool {
        var permissionCheck: Bool = false
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            permissionCheck = true
        case .denied:
            permissionCheck = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                permissionCheck = granted
            }
        @unknown default:
            break
        }
        return permissionCheck
    }
}

extension AudioRecorder {

    func generateAudioName() {
        self.audioName = UUID().uuidString
    }

    func setAudioName(_ name: String) {
        self.audioName = name
    }
}
