//
//  SlideView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 21/11/2024.
//

import SwiftUI

struct SlideView: View {
    @Environment(AppModel.self) private var appModel
    @Binding var slide: Slide?
    @State private var showImageImporter = false

    var body: some View {
        VStack {
            if let imageView {
                imageView
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
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
                        appModel.errorToShowInAlert = error
                    }
                case .failure(let error):
                    appModel.errorToShowInAlert = error
                }
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

