//
//  RecordingButton.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.09.2023.
//

import SwiftUI
import RealmSwift
import AVFoundation

struct RecordingButton: View {
    @ObservedObject var audioRecorder: AudioRecorder
    var audioName: String?
    var perform: (URL?) -> Void
    @State private var showAlert: Bool = false

    var body: some View {
        Button {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                    perform(audioRecorder.audioURL)
                } else {
                    if let audioName {
                        audioRecorder.setAudioName(audioName)
                    } else {
                        audioRecorder.generateAudioName()
                    }
                    audioRecorder.startRecording()
                }
            case .denied:
                    showAlert.toggle()
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { _ in }
            @unknown default:
                break
            }
        } label: {
            if audioRecorder.isRecording {
                Image(systemName: "stop.circle")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .blue)
            } else {
                Image(systemName: "mic.fill.badge.plus")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .blue)
            }
        }
        .alert("No access", isPresented: $showAlert, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button("Open settings", role: .none) {

            }
        })
    }
}

struct RecordingButton_Previews: PreviewProvider {
    static var previews: some View {
        RecordingButton(audioRecorder: AudioRecorder(), perform: { _ in })
    }
}
