//
//  ReviewView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.09.2023.
//

import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss

    @State private var isShowAnswer: Bool = false
    @StateObject var reviewManager: ReviewManagerSUI

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if reviewManager.isReviewing {
                        Text(reviewManager.currentCard?.front ?? "")

                        Group {
                            Divider()
                            Text(reviewManager.currentCard?.back ?? "No back text")
                        }
                        .opacity(isShowAnswer ? 1 : 0)
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
                        SoundManager.shared.play(sound: reviewManager.currentCard?.audioName ?? "")
                    }
                }
                .font(.system(size: 40, weight: .medium))
                .padding()
                .onAppear {
                    reviewManager.startReview()
                }
                .onChange(of: reviewManager.currentCard) {
                    playPronunciation()
                }

                VStack {
                    Spacer()
                    if reviewManager.isReviewing {
                        Button {
                            if isShowAnswer {
                                reviewManager.nextCard()
                                isShowAnswer = false
                            } else {
                                isShowAnswer = true
                            }
                            HapticManagerSUI.shared.impact(style: .medium)
                        } label: {
                            Image(systemName: isShowAnswer ? "arrow.right.circle.fill" : "eye.circle.fill")
                        }
                    } else {
                        Button {
                            reviewManager.startReview()
                            isShowAnswer = false
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
            SoundManager.shared.play(sound: audioName)
        }
    }

}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(reviewManager: ReviewManagerSUI(cards: Deck.deck2.cards))
    }
}
