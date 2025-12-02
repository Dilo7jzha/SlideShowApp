//
//  SlidePresentationView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 11/10/2025.
//

import SwiftUI

struct SlidePresentationView: View {
    let slide: Slide?
    @Environment(AppModel.self) private var appModel
    
#if os(macOS) || os(visionOS)
    @Environment(\.openWindow) private var openWindow
#endif
    
    var isEditable: Bool = true // Controls whether editing features (text and image) are enabled
    
    var body: some View {
        let title = appModel.selectedStoryNode?.name
        VStack(spacing: 20) {
            if let title {
                Text(title)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
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
            }
            
            if let slideText = slide?.text, !slideText.isEmpty {
                Text(slideText)
                    .font(.system(size: 26))
                    .frame(maxWidth: 550)
                    .padding()
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }

    }
    
    private func openImageViewer() {
        guard let image = slide?.image else { return }
        appModel.currentImageForViewer = image
        appModel.isImageViewerOpen = true // Mark image viewer as open
        openWindow(id: "ImageViewer")
    }
    
    private var imageView: Image? {
        guard let image = slide?.image else { return nil }
#if canImport(UIKit)
        return Image(uiImage: image.image)
#elseif canImport(AppKit)
        return Image(nsImage: image.image)
#endif
    }
}
