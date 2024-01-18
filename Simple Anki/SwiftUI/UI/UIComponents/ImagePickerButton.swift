////
////  ImagePickerButton.swift
////  Simple Anki
////
////  Created by Астемир Бозиев on 12.01.2024.
////
//
import SwiftUI
import PhotosUI

struct ImagePickerButton: View {

    @Binding var image: UIImage?
    @State private var selectedImage: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedImage, matching: .images) {
            Image(systemName: "photo")
                .overlay {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .contextMenu {
                                Button(role: .destructive) {
                                    clearSelection()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                            }
                    }
                }
        }
        .onChange(of: selectedImage) {
            selectImage()
        }

    }

    private func selectImage() {
        Task {
            let data = try? await selectedImage?.loadTransferable(type: Data.self)
            self.image = UIImage(data: data ?? Data())
        }
    }

    private func clearSelection() {
        self.image = nil
        self.selectedImage = nil
    }
}

#Preview {
    ImagePickerButton(image: .constant(UIImage(data: Data())))
}
