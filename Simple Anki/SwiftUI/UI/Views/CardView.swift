//
//  CardView.swift
//  Simple Anki
//
//  Created by Astemir Boziev on 08.09.2023.
//

import SwiftUI
import RealmSwift
import SPIndicator
import PhotosUI

struct CardView: View {
    @ObservedRealmObject var card: Card

    @State private var recordingButtonSize: CGFloat = 18
    @State private(set) var image: UIImage?
    @State private var selectedImage: PhotosPickerItem?
    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State private var isPreviewPresented: Bool = false

    private var transaction: Transaction {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var audioRecorder: AudioRecorder

    var body: some View {
        // MARK: VSTACK START
        VStack {
            Spacer()

            VStack {
                TextField("Front word", text: $frontText)
                    .padding(.bottom)
                Divider()
                TextField("Back word", text: $backText)
                    .padding(.top)
            }
            .focused($isTextFieldFocused)
            .font(.system(size: 35, weight: .medium))
            .multilineTextAlignment(.center)
            .padding()
            .onAppear {
                frontText = card.front
                backText = card.back
                isTextFieldFocused.toggle()
                print(card)
            }

            Spacer()

            // MARK: ZSTACK START
            ZStack {
                // MARK: HSTACK START
                HStack {
                    Group {
                        ImagePickerButton(image: $image)

                        Spacer()

                        Button {
                            guard let image = image else { return }
                            guard !frontText.isEmpty else { return }
                            writeToDisk(image: image, imageName: frontText + UUID().uuidString)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 35))
                        }
                        .disabled(frontText.isEmpty)
                    }
                    .opacity(audioRecorder.isRecording ? 0 : 1)
                    .offset(x: audioRecorder.isRecording ? -200 : 0)
                    .animation(.easeInOut(duration: 0.3), value: audioRecorder.isRecording)

                    Spacer()

                    Button {
                        audioRecorder.isRecording.toggle()
                        HapticManagerSUI.shared.impact(style: .heavy)
                    } label: {
                        Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "waveform.badge.mic")
                            .foregroundStyle(audioRecorder.isRecording ? .red : .blue)
                            .font(.system(size: audioRecorder.isRecording ? 35 : 18))
                            .contentTransition(.symbolEffect(.replace.offUp.wholeSymbol))
                    }
                    .contextMenu {
                        Button {
                            print("delete audio")
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                } // MARK: HSTACK END
                .padding(.horizontal)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity)

                Text("Recording...")
                    .padding(.bottom, 3)
                    .foregroundStyle(.gray)
                    .offset(x: audioRecorder.isRecording ? 0 : 100)
                    .opacity(audioRecorder.isRecording ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: audioRecorder.isRecording)
            } // MARK: ZSTACK END
        } // MARK: VSTACK END
        .onChange(of: selectedImage) {
            Task {
                let data = try? await selectedImage?.loadTransferable(type: Data.self)
                self.image = UIImage(data: data ?? Data())
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Preview") {
                    withTransaction(transaction) {
                        isPreviewPresented.toggle()
                    }
                }
                .fullScreenCover(isPresented: $isPreviewPresented) {
                    CardPreviewView(front: frontText, back: backText, image: image, audio: card.audioName, isPreviewPresented: $isPreviewPresented)
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray)
                }
            }
        }
    }

    private func writeToDisk(image: UIImage, imageName: String) {
        let savePath = FileManager.documentsDirectory.appendingPathComponent("\(imageName).jpg")
        if let jpegData = image.jpegData(compressionQuality: 0.5) {
            try? jpegData.write(to: savePath, options: [.atomic, .completeFileProtection])
            print("Image saved")
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardView(card: Card.card)
                .environmentObject(AudioRecorder())
        }
    }
}
