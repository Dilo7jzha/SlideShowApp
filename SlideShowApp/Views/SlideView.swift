//
//  SlideView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 21/11/2024.
//

import SwiftUI

struct SlideView: View {
    @Binding var slide: Slide?
    @State private var showImageImporter = false
    var isEditable: Bool = true // Controls whether editing features (text and image) are enabled

    var body: some View {
        VStack {
            // Show the image or placeholder text
            if let imageView {
                imageView
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
                    .padding()
            }
            
            // Add Image button is shown only if editing is enabled
            if isEditable {
                Button(action: {
                    showImageImporter = true
                }) {
                    Label("Add Image", systemImage: "photo")
                }
                .fileImporter(isPresented: $showImageImporter, allowedContentTypes: [.image]) { result in
                    switch result {
                    case .success(let url):
                        do {
                            guard url.startAccessingSecurityScopedResource() else {
                                throw error("Cannot access file.")
                            }
                            defer { url.stopAccessingSecurityScopedResource() }
                            slide?.image = try CodableImage(url: url)
                        } catch {
                            print("Error adding image: \(error.localizedDescription)")
                        }
                    case .failure(let error):
                        print("Error selecting file: \(error.localizedDescription)")
                    }
                }
            }

            // Text view is editable only if editing is enabled
            if isEditable {
                TextEditor(text: textBinding)
                    .font(.title)
                    .padding()
                    .border(Color.gray, width: 1)
            } else if let slideText = slide?.text, !slideText.isEmpty, slideText != "Enter text here" {
                Text(slideText)
                    .font(.title)
                    .padding()
                    .border(Color.gray, width: 1)
                    .foregroundColor(.secondary)
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
            get: { slide?.text ?? "" },
            set: { slide?.text = $0 })
    }
}
