//
//  NewDeckView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 10.02.2024.
//

import SwiftUI

struct NewDeckView: View {
    @State private var selectedSegment: Int = 0
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                if selectedSegment == 0 {
                    CreateDeckView()
                } else {
                    ImportDeckView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("test", selection: $selectedSegment) {
                        Text("Create").tag(0)
                        Text("Import").tag(1)
                    }
                    .frame(width: 200)
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}

#Preview {
    NewDeckView()
}
