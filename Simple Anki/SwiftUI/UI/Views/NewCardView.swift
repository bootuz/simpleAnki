//
//  NewCardView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 20.08.2023.
//

import SwiftUI
import RealmSwift

struct NewCardView: View {
    @ObservedRealmObject var deck: Deck

    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State private var isAlerPresented: Bool = false

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusableField?

    @State private var audioName: String?

    init(deck: Deck) {
        self.deck = deck
    }

    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 30) {
                    TextField("Front", text: $frontText)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .frontField)
                    Divider()
                    TextField("Back", text: $backText)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .backField)
                }
                .onAppear {
                    focusedField = .frontField
                }
                .onSubmit {
                    focusedField = .backField
                }
                .font(.system(size: 35, weight: .bold))
                .padding(.top, 50)
                Divider()
                HStack {
                    if let audio = audioName {
                        Button {
                            isAlerPresented.toggle()
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                        .alert("Delete audio file?", isPresented: $isAlerPresented, actions: {
                            Button("Delete", role: .destructive) {
                                LocalFileManager.shared.delete(audio)
                                audioName = nil
                            }
                        })
                        .tint(.red)

                        Button {
                            SoundManager.shared.play(sound: audio)
                        } label: {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                    }
                    Spacer()
//                    RecordingButton(audioRecorder: AudioRecorder()) { audioURL in
//                        audioName = audioURL?.lastPathComponent
//                    }
                }
                .padding(.top, 8)
                .font(.system(size: 20, weight: .bold))
            }
            Spacer()
            Button {
                saveCard()
                focusedField = .frontField
                frontText.removeAll()
                backText.removeAll()
                audioName = nil
                HapticManagerSUI.shared.impact(style: .heavy)
            } label: {
                Text("Add")
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
            .disabled(frontText.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Add card to \(deck.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if let audio = audioName {
                        LocalFileManager.shared.delete(audio)
                    }
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func saveCard() {
        let front = frontText.trimmingCharacters(in: .whitespacesAndNewlines)
        let back = backText.trimmingCharacters(in: .whitespacesAndNewlines)
        let card = Card(front: front, back: back, audioName: audioName)
        $deck.cards.append(card)
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 2 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NewCardView_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    static var previews: some View {
        NavigationView {
            NewCardView(deck: Deck.deck1)
        }
    }
}
