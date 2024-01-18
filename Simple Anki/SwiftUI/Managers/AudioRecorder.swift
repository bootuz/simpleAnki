//
//  RecorderManager.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.09.2023.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isPlaybackReady = false
    @Published var isRecording = false

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var fileName: String?

    init(fileName: String? = nil) {
        self.fileName = fileName ?? UUID().uuidString + ".m4a"
        super.init()
        setupRecorder()
    }

    private var settings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2
    ]

    private func setupRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            guard let fileName = fileName else { return }
            let fileURL = getDocumentsDirectory().appendingPathComponent("\(fileName)")

            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
        } catch {
            print("Error setting up audio recorder: \(error.localizedDescription)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func startRecording() {
        audioRecorder?.record()
        isRecording = true
    }

    func stopRecording(completion: @escaping (String?) -> Void) {
        audioRecorder?.stop()
        isRecording = false
        isPlaybackReady = true
        completion(fileName ?? nil)
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

    func playRecording() {
        guard isPlaybackReady, let url = audioRecorder?.url else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("Failed to initialize the audio player: \(error.localizedDescription)")
        }
    }

    func deleteRecording() {
        guard let fileName = fileName else { return }

        let url = getDocumentsDirectory().appendingPathComponent("\(fileName)")

        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }
}
