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
            if let imageView {
                imageView
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
#if canImport(UIKit)
#warning("TBD")
                ImagePicker(selectedImage: imageBinding)
#endif
            }
        }
    }
    
    private var imageView: Image? {
        guard let image = slide?.image else { return nil }
#if canImport(UIKit)
        return Image(uiImage: image.image)
#elseif canImport(AppKit)
        return Image(nsImage: image.image)
#endif
    }
    
    private var textBinding: Binding<String> {
        Binding<String>(
            get: { slide?.text ?? ""  },
            set: { slide?.text = $0 })
    }
    
    private var imageBinding: Binding<PlatformImage?> {
        Binding<PlatformImage?>(
            get: { slide?.image?.image },
            
            set: { newImage in
                if let newImage {
                    slide?.image = CodableImage(image: newImage)
                } else {
                    slide?.image = nil
                }
            })
    }
}

