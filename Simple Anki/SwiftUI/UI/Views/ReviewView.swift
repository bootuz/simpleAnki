//
//  ReviewView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.09.2023.
//

import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss

    @State private var isAnswerPresented: Bool = false
    @State var reviewManager: ReviewManagerSUI

    var body: some View {
        NavigationView {
            ZStack {
                if let image = reviewManager.currentCard?.image {
                    VStack {
                        Image(uiImage: UIImage(imageLiteralResourceName: image))
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 150, height: 150)
                            .padding(.top, 60)
                        Spacer()
                    }
                }
                VStack {
                    if reviewManager.isReviewing {
                        Text(reviewManager.currentCard?.front ?? "")

                        Group {
                            Divider()
                            Text(reviewManager.currentCard?.back ?? "No back text")
                        }
                        .opacity(isAnswerPresented ? 1 : 0)
                    } else {
                        Text("Finished!")
                            .font(.system(size: 60, weight: .bold))
                    }
                }
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .onTapGesture {
                    if reviewManager.isReviewing {
                        playPronunciation()
                    }
                }
                .font(.system(size: 40, weight: .medium))
                .padding()
                .onAppear {
                    reviewManager.startReview()
                    if reviewManager.isAutoplayOn {
                        playPronunciation()
                    }
                }
                .onChange(of: reviewManager.currentCard) {
                    if reviewManager.isAutoplayOn {
                        playPronunciation()
                    }
                }

                VStack {
                    Spacer()
                    if reviewManager.isReviewing {
                        Button {
                            if isAnswerPresented {
                                reviewManager.nextCard()
                                isAnswerPresented = false
                            } else {
                                isAnswerPresented = true
                            }
                            HapticManagerSUI.shared.impact(style: .medium)
                        } label: {
                            Image(systemName: isAnswerPresented ? "arrow.right.circle.fill" : "eye.circle.fill")
                        }
                    } else {
                        Button {
                            reviewManager.startReview()
                            isAnswerPresented = false
                            HapticManagerSUI.shared.impact(style: .medium)
                        } label: {
                            Image(systemName: "repeat.circle.fill")
                        }
                    }
                }
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.6))
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Text("Tap on front word to play a sound")
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    private func playPronunciation() {
        if let audioName = reviewManager.currentCard?.audioName {
            DispatchQueue.global(qos: .background).async {
                SoundManager.shared.play(sound: audioName)
            }
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(reviewManager: ReviewManagerSUI(deck: Deck.deck2))
    }
}
