//
//  CardView.swift
//  Simple Anki
//
//  Created by Astemir Boziev on 08.09.2023.
//

import SwiftUI
import RealmSwift
import PhotosUI

struct CardView: View {
    @State var viewModel: CardViewModel
    @ObservedRealmObject var deck: Deck

    @State private var selectedImage: PhotosPickerItem?
    @State private var isPreviewPresented: Bool = false
    @State private var showAlert: Bool = false

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
                TextField("Front word", text: $viewModel.frontWord)
                    .padding(.bottom)
                Divider()
                TextField("Back word", text: $viewModel.backWord)
                    .padding(.top)
            }
            .focused($isTextFieldFocused)
            .font(.system(size: 35, weight: .medium))
            .multilineTextAlignment(.center)
            .padding()
            .onAppear {
                isTextFieldFocused.toggle()
            }

            Spacer()

            // MARK: ZSTACK START
            ZStack {
                // MARK: HSTACK START
                HStack {
                    Group {
                        ImagePickerButton(image: $viewModel.image)

                        Spacer()

                        Button {
                            guard !viewModel.frontWord.isEmpty else { return }
                            if viewModel.updating {
                                 update()
                            } else {
                                addCard()
                                viewModel.clear()
                            }
//                            writeToDisk(image: image, imageName: viewModel.frontWord + UUID().uuidString)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 35))
                        }
                    }
                    .opacity(audioRecorder.isRecording ? 0 : 1)
                    .offset(x: audioRecorder.isRecording ? -200 : 0)
                    .animation(.easeInOut(duration: 0.3), value: audioRecorder.isRecording)

                    Spacer()

                    if let fileName = viewModel.audioName {
                        Button {
                            Task {
                                SoundManager.shared.play(sound: fileName)
                            }
                        } label: {
                            Image(systemName: "play.circle")
                                .font(.system(size: 18))
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                audioRecorder.deleteRecording()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    } else {
                        Button {
                            HapticManagerSUI.shared.impact(style: .heavy)

                            if audioRecorder.isRecording {
                                audioRecorder.stopRecording { fileName in
                                    viewModel.audioName = fileName
                                }
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
                viewModel.image = UIImage(data: data ?? Data())
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Preview") {
                    withTransaction(transaction) {
                        isPreviewPresented.toggle()
                    }
                }
                .disabled(viewModel.incomplete)
                .fullScreenCover(isPresented: $isPreviewPresented) {
                    CardPreviewView(front: viewModel.frontWord, back: viewModel.backWord, image: viewModel.image, audio: viewModel.audioName, isPreviewPresented: $isPreviewPresented)
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

    private func update() {
        guard let cardID = viewModel.id else { return }
        guard let card = deck.cards.first(where: {$0._id == cardID }) else { return }

        do {
            let realm = try Realm()
            try realm.write {
                card.thaw()?.front = viewModel.frontWord
                card.thaw()?.back = viewModel.backWord
                card.thaw()?.audioName = viewModel.audioName
                card.thaw()?.memorized = viewModel.memorized
            }
        } catch {
            print("Error: \(error)")
        }
    }

    private func addCard() {
        let card = Card(
            front: viewModel.frontWord,
            back: viewModel.backWord,
            audioName: viewModel.audioName
        )
        $deck.cards.append(card)
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
            CardView(viewModel: CardViewModel(), deck: Deck.deck1)
                .environmentObject(AudioRecorder())
        }
    }
}
