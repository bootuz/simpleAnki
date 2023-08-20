//
//  NewCardView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 20.08.2023.
//

import SwiftUI

struct NewCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPopoverPresented: Bool

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        isPopoverPresented = false
                    }
                }
            }
    }
}

struct NewCardView_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    static var previews: some View {
        NewCardView(isPopoverPresented: $isPresented)
    }
}
