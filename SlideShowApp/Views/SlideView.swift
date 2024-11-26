//
//  SlideView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 21/11/2024.
//

import SwiftUI

struct SlideView: View {
    @Binding var slide: Slide?
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            if let image = slide?.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("No Image")
                    .font(.headline)
                    .padding()
            }
            
            TextEditor(text: textBinding)
                .font(.title)
                .padding()
                .border(Color.gray, width: 1)
            
            Button(action: {
                isImagePickerPresented = true
            }) {
                Label("Add Image", systemImage: "photo")
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: imageBinding)
            }
        }
    }
    
    private var textBinding: Binding<String> {
        Binding<String>(
            get: { slide?.text ?? ""  },
            set: { slide?.text = $0 })
    }
    
    private var imageBinding: Binding<UIImage?> {
        Binding<UIImage?>(
            get: { slide?.image },
            set: { slide?.image = $0 })
    }
}

