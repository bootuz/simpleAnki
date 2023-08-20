//
//  NewDeckView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 20.08.2023.
//

import SwiftUI

struct NewDeckView: View {
    @State private var deckNameText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Binding var isPopoverPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                TextField("Deck name", text: $deckNameText)
                    .background()
                    .font(.system(size: 35, weight: .bold))
                    .padding(.top, 160)
                    .focused($isTextFieldFocused)
                Spacer()
                NavigationLink {
                    NewCardView(isPopoverPresented: $isPopoverPresented)
                } label: {
                    HStack {
                        Text("Add cards")
                        Image(systemName: "arrow.right")
                    }
                    .padding(8)
                    .frame(maxWidth: 280)
                }
                .disabled(deckNameText.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .onAppear {
                isTextFieldFocused.toggle()
            }
            .navigationTitle(deckNameText)
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if !deckNameText.isEmpty {

                        }
                        isPopoverPresented.toggle()
                    }
                }
            }
        }
    }
}

struct NewDeckView_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    static var previews: some View {
        NewDeckView(isPopoverPresented: $isPresented)
    }
}
