//
//  SlideDetailView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 21/11/2024.
//

import SwiftUI

struct SlideDetailView: View {
    @Binding var slide: Slide
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            if let image = slide.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("No Image")
                    .font(.headline)
                    .padding()
            }

            TextEditor(text: $slide.text)
                .font(.title)
                .padding()
                .border(Color.gray, width: 1)
            
            Button(action: {
                            isImagePickerPresented = true
                        }) {
                            Label("Add Image", systemImage: "photo")
                        }
                        .padding()
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(selectedImage: $slide.image)
                        }
        }
        .navigationTitle("Edit Slide")
    }
}

