//
//  LinkView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.08.2023.
//

import SwiftUI

struct LinkView: View {
    let label: String
    let urlString: String
    let icon: Image

    var body: some View {
        Link(destination: URL(string: urlString)!) {
            HStack {
                Label {
                    Text(label)
                        .foregroundColor(.primary)
                } icon: {
                    icon
                }
                Spacer()
                Image(systemName: "arrow.up.forward.app")
                    .foregroundColor(.pink)
                    .font(.system(size: 10))
            }
        }
    }
}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(label: "Review app", urlString: "test", icon: Image(systemName: "star"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
