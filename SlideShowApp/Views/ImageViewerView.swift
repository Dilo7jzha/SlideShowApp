//
//  ImageViewerView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 15/6/2025.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ImageViewerView: View {
    let image: CodableImage?
    @Environment(AppModel.self) private var appModel
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
#if os(iOS)
    @Environment(\.dismiss) private var dismiss
#elseif os(visionOS)
    @Environment(\.dismissWindow) private var dismissWindow
#endif
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea(.all)
                
                if let imageView = createImageView() {
                    imageView
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                // Magnification gesture for zooming
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = max(0.5, min(value, 5.0))
                                    },
                                
                                // Drag gesture for panning
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            // Double tap to reset zoom and position
                            withAnimation(.easeInOut(duration: 0.3)) {
                                scale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                } else {
                    Text("No image available")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                // Overlay controls at the top
                VStack {
                    HStack {
#if os(iOS)
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
#else
                        Button("Close") {
                            closeWindow()
                        }
                        .foregroundColor(.white)
                        .padding()
#endif
                        
                        Spacer()
                        
                        Button("Reset") {
                            resetImageView()
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    Spacer()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .ignoresSafeArea(.all)
    }
    
    private func resetImageView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }
    
    private func closeWindow() {
#if os(macOS)
        // Close the current window on macOS
        if let window = NSApplication.shared.keyWindow {
            window.close()
        }
#elseif os(visionOS)
        // Use dismissWindow for visionOS
        dismissWindow(id: "ImageViewer")
#endif
        // Clear the current image reference
        appModel.currentImageForViewer = nil
    }
    
    private func createImageView() -> Image? {
        guard let imageData = self.image else { return nil }
#if canImport(UIKit)
        return Image(uiImage: imageData.image)
#elseif canImport(AppKit)
        return Image(nsImage: imageData.image)
#endif
    }
}
