//
//  LayoutButton.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 04.02.2024.
//

import SwiftUI
import RealmSwift

struct LayoutButton: View {
    var labelText: String
    var layout: String

    @ObservedRealmObject var deck: Deck
    @Environment(\.realm) var realm

    var body: some View {
        Button {
            do {
                let thawedDeck = deck.thaw()
                try realm.write {
                    thawedDeck?.layout = layout
                }
            } catch {
                print(error)
            }
            HapticManagerSUI.shared.impact(style: .light)
        } label: {
            HStack {
                Text(labelText)

                Spacer()

                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
                    .opacity(deck.layout == layout ? 1 : 0)
            }
        }
        .tint(.primary)
    }
}

#Preview {
    LayoutButton(labelText: "Front to Back", layout: K.Layout.frontToBack, deck: Deck.deck1)
        .padding()
}
