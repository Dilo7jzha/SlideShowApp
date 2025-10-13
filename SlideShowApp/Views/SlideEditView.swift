//
//  SlideEditView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 21/11/2024.
//

import SwiftUI

struct SlideEditView: View {
    @Binding var slide: Slide?
    @Environment(AppModel.self) private var appModel
    @State private var showImageImporter = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let imageView {
                imageView
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .padding()
                    .help("Tap to view image in separate window") // macOS tooltip
                    .accessibilityLabel("Slide image, tap to open in separate window")
            } else {
                Color.clear.frame(height: 40)
            }
            
            // Add Image button (edit mode only)
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
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray)
                TextEditor(text: textBinding)
                    .padding()
            }
            
            Spacer()
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
