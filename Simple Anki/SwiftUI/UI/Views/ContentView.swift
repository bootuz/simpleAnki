//
//  TransitionDemo.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 11.01.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var text: String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            // Your main content here
            // ...
            VStack {
                TextField("test", text: $text)
                CustomToolbar()
                    .padding(.bottom, keyboardHeight)
            }


        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                let height = value.height
                keyboardHeight = height
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
    }
}

struct CustomToolbar: View {
    var body: some View {
        HStack {
            Button("Left") {
                // Action for left button
            }
            Spacer()
            Button("Middle") {
                // Action for middle button
            }
            Spacer()
            Button("Right") {
                // Action for right button
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // Just for visibility
    }
}

#Preview {
    ContentView()
}
