//
//  DelimeterButton.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 11.02.2024.
//

import SwiftUI
import SwiftCSV

struct DelimeterButton: View {
    var title: String
    var delimeter: CSVDelimiter
    @Binding var selectedDelimeter: CSVDelimiter
    var body: some View {
        Button(action: {
            selectedDelimeter = delimeter
        }, label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
                    .opacity(selectedDelimeter == delimeter ? 1: 0)
            }
        })
        .tint(.primary)
    }
}

#Preview {
    DelimeterButton(title: "Comma", delimeter: .comma, selectedDelimeter: .constant(.comma))
}
