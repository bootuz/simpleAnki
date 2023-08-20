//
//  DecksView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 16.08.2023.
//

import SwiftUI

struct DecksView: View {
    @EnvironmentObject var realmManager: RealmManager
    @State private var isPopoverPresented: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if realmManager.decks.isEmpty {
                    Spacer()

                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 120, weight: .light))
                        Text("There are no decks yet")
                    }
                    .foregroundColor(.gray.opacity(0.7))

                    Spacer()

                    Button {
                        isPopoverPresented.toggle()
                    } label: {
                        Text("Add deck")
                            .padding(8)
                            .frame(maxWidth: 280)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 40)
                    .popover(isPresented: $isPopoverPresented) {
                        NewDeckView(isPopoverPresented: $isPopoverPresented)
                    }
                } else {
                    List {
                        ForEach(realmManager.decks) { deck in
                            Text(deck.name)
                        }
                    }
                    .onAppear {
                        print(realmManager.decks)
                    }
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        print("Test")
                    } label: {
                        Image(systemName: "tray.and.arrow.down")
                    }
                    Button {
                        isPopoverPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popover(isPresented: $isPopoverPresented) {
                        NewDeckView(isPopoverPresented: $isPopoverPresented)
                    }
                }
            }
        }
    }
}

struct DecksView_Previews: PreviewProvider {
    static var previews: some View {
        DecksView()
            .environmentObject(RealmManager())
    }
}
