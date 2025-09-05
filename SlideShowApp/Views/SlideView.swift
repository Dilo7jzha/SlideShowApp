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
    @State private var showImageViewer = false // Fallback for iOS
    @Environment(AppModel.self) private var appModel
    
#if os(macOS) || os(visionOS)
    @Environment(\.openWindow) private var openWindow
#endif
    
    var isEditable: Bool = true // Controls whether editing features (text and image) are enabled
    
    var body: some View {
        VStack {
            if let imageView, !appModel.isImageViewerOpen {
                imageView
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .padding()
                    .onTapGesture {
                        openImageViewer()
                    }
                    .help("Tap to view image in separate window") // macOS tooltip
                    .accessibilityLabel("Slide image, tap to open in separate window")
            } else {
                Color.clear.frame(height: 40)
            }
            
            // Add Image button (edit mode only)
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
                            appModel.errorToShowInAlert = error
                        }
                    case .failure(let error):
                        appModel.errorToShowInAlert = error
                    }
                }
            }
            
            // Text section
            if isEditable {
                TextEditor(text: textBinding)
                    .padding()
                    .border(Color.gray)
            } else if let slideText = slide?.text, !slideText.isEmpty, slideText != "Enter text here" {
                Text(slideText)
                    .font(.system(size: 26))
                    .frame(maxWidth: 550)
                    .padding()
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
#if os(iOS)
        // Fallback to sheet on iOS since separate windows aren't available
        .sheet(isPresented: $showImageViewer) {
            NavigationView {
                if let image = slide?.image {
                    ImageViewerView(image: image)
                        .environment(appModel)
                }
            }
        }
#endif
    }
    
    private func openImageViewer() {
        guard let image = slide?.image else { return }
        
        appModel.currentImageForViewer = image
        appModel.isImageViewerOpen = true // Mark image viewer as open
        
#if os(macOS)
        openWindow(id: AppModel.imageViewerWindowID)
#elseif os(visionOS)
        openWindow(id: "ImageViewer")
#elseif os(iOS)
        // Fall back to sheet presentation on iOS
        showImageViewer = true
#endif
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
