//
//  CircleButton.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.09.2023.
//

import Foundation
import SwiftUI

struct CircleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Circle())
    }
}
