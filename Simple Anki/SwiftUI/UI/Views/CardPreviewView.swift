//
//  CardPreviewView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 12.01.2024.
//

import SwiftUI

struct CardPreviewView: View {

    @Binding var isPreviewPresented: Bool

    var front: String
    var back: String?
    var image: UIImage?
    var audio: String?

    private var transaction: Transaction {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }

    init(front: String, back: String?, image: UIImage? = nil, audio: String? = nil, isPreviewPresented: Binding<Bool>) {
        self.front = front
        self.back = back
        self.image = image
        self.audio = audio
        self._isPreviewPresented = isPreviewPresented
    }

    var body: some View {
        NavigationView {
            ZStack {
                if let image {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 150, height: 150)
                            .padding(.top, 60)
                        Spacer()
                    }
                }

                VStack {
                    Text(front)

                    Group {
                        Divider()
                        Text(back ?? "")
                    }
                }
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .onTapGesture {
                    SoundManager.shared.play(sound: audio ?? "")
                }
                .font(.system(size: 35, weight: .medium))
                .padding()

                if let audio {
                    VStack {
                        Spacer()

                        Button(action: {

                        }, label: {
                            Image(systemName: "speaker.wave.2.circle")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(.black)
                        })
                        .padding(.bottom, 140)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        withTransaction(transaction) {
                            isPreviewPresented.toggle()
                        }
                    } label: {
                        Text("Back")
                    }
                }
            }
        }
    }
}

#Preview {
    CardPreviewView(front: "Hello", back: "Привет", image: UIImage(systemName: "photo"), audio: "test", isPreviewPresented: .constant(true))
}
