//
//  CardView.swift
//  Simple Anki
//
//  Created by Astemir Boziev on 08.09.2023.
//

import SwiftUI
import RealmSwift
import PhotosUI
import Pow

enum FocusableField: Hashable {
    case frontField
    case backField
}

struct CardView: View {
    @State var viewModel: CardViewModel
    @State var recorder: AudioRecorder

    @State private var selectedImage: PhotosPickerItem?
    @State private var isPreviewPresented: Bool = false
    @State private var showAlert: Bool = false
    @State private var saveButtonTapped: Bool = false
    @FocusState private var focusedField: FocusableField?

    private var transaction: Transaction {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // MARK: VSTACK START
        VStack {
            Spacer()

            // MARK: VSTACK START
            VStack {
                TextField("Front word", text: $viewModel.frontWord)
                    .padding(.bottom)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .frontField)
                    .onSubmit {
                        focusedField = .backField
                    }
                Divider()
                TextField("Back word", text: $viewModel.backWord)
                    .padding(.top)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .backField)
            } // MARK: VSTACK END
            .font(.system(size: 35, weight: .medium))
            .multilineTextAlignment(.center)
            .padding()
            .onAppear {
                focusedField = .frontField
            }

            Spacer()

            // MARK: ZSTACK START
            ZStack {
                // MARK: HSTACK START
                HStack {
                    Group {
                        ImagePickerButton(image: $viewModel.image)
                            .hidden()

                        Spacer()

                        Button {
                            guard !viewModel.frontWord.isEmpty else { return }
                            if viewModel.updating {
                                viewModel.updateCard()
                            } else {
                                viewModel.addCard()
                                viewModel.clear()
                                recorder.setName(UUID().uuidString + ".m4a")
                            }
                            withAnimation {
                                saveButtonTapped.toggle()
                            }
                            HapticManagerSUI.shared.impact(style: .heavy)
                        } label: {
                            Text(viewModel.updating ? "Update" : "Save")
                        }
                        .changeEffect(
                            .rise(origin: UnitPoint(x: 0.45, y: -11)) {
                                Text(viewModel.updating ? "Updated" : "Added")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.blue)
                          }, value: saveButtonTapped)
                        .controlSize(.extraLarge)
                        .buttonStyle(.borderedProminent)
                    }
                    .opacity(recorder.isRecording ? 0 : 1)
                    .offset(x: recorder.isRecording ? -200 : 0)
                    .animation(.easeInOut(duration: 0.3), value: recorder.isRecording)

                    Spacer()

                    if let fileName = viewModel.audioName {
                        Button {
                            SoundManager.shared.play(sound: fileName)
                        } label: {
                            Image(systemName: "play.circle")
                                .font(.system(size: 18))
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteAudioAndUpdateCard()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    } else {
                        Button {
                            HapticManagerSUI.shared.impact(style: .heavy)

                            if recorder.isRecording {
                                recorder.stopRecording { fileName in
                                    viewModel.audioName = fileName
                                }
                            } else {
                                recorder.checkRecordPermission { granted in
                                    if granted {
                                        DispatchQueue.global(qos: .background).async {
                                            recorder.startRecording()
                                        }
                                    } else {
                                        showAlert.toggle()
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: recorder.isRecording ? "stop.circle.fill" : "waveform.badge.mic")
                                .foregroundStyle(recorder.isRecording ? .red : .blue)
                                .font(.system(size: recorder.isRecording ? 35 : 18))
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
                    .offset(x: recorder.isRecording ? 0 : 100)
                    .opacity(recorder.isRecording ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: recorder.isRecording)
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

            ToolbarItem(placement: .principal) {
            }

            ToolbarItem(placement: .cancellationAction) {
                Button {
                    FileManager.default.delete(viewModel.audioName)
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

    private func deleteAudioAndUpdateCard() {
        viewModel.audioName = nil
        recorder.deleteRecording()
        viewModel.updateCard()
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardView(viewModel: CardViewModel(repositry: CardRepository(deck: Deck.deck1)), recorder: AudioRecorder(fileName: UUID().uuidString + ".m4a"))
        }
    }
}
