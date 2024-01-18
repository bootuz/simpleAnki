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
    @State private var showAlert: Bool = false

    var body: some View {
        Button {
            if audioRecorder.isRecording {
//                audioRecorder.stopRecording()
            } else {
                audioRecorder.checkRecordPermission { granted in
                    if granted {
                        audioRecorder.startRecording()
                    } else {
                        showAlert.toggle()
                    }
                }
            }
        } label: {
            Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "waveform.badge.mic")
                .foregroundStyle(audioRecorder.isRecording ? .red : .blue)
                .font(.system(size: audioRecorder.isRecording ? 35 : 18))
                .contentTransition(.symbolEffect(.replace.offUp.wholeSymbol))
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
        RecordingButton(audioRecorder: AudioRecorder())
    }
}
