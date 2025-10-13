//
//  PresentationView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 13/12/2024.
//

import SwiftUI

struct PresentationView: View {
    @Environment(AppModel.self) private var appModel
    @State private var currentIndex = 0

    var body: some View {
        VStack {
            if let currentStoryNode = appModel.story.storyNodes[safe: currentIndex] {
                SlidePresentationView(slide: currentStoryNode.slide)
                    .padding()
            } else {
                Spacer()
                ContentUnavailableView("No Slides", systemImage: "play.rectangle.on.rectangle")
            }

            Spacer() // Pushes buttons towards the bottom

            // Navigation Buttons
            HStack {
                Spacer()
                
                Group {
                    Button(action: { goToStoryNode(at: currentIndex - 1) }) {
                        Label("Previous", systemImage: "arrow.left")
                    }
                    .disabled(currentIndex <= 0)
                    
                    // Return Button at the Bottom
                    Button(action: { appModel.isPresenting = false }) {
                        Label("Return", systemImage: "xmark.circle")
                    }
                    .padding(.horizontal)
                    
                    Button(action: { goToStoryNode(at: currentIndex + 1) }) {
                        Label("Next", systemImage: "arrow.right")
                    }
                    .disabled(currentIndex >= appModel.story.storyNodes.count - 1)
                }
                .controlSize(.extraLarge)
                .labelStyle(.iconOnly)
                Spacer()
            }
            .padding(26)
        }
        .navigationTitle("Presentation")
    }

    private func goToStoryNode(at index: Int) {
        guard index >= 0, index < appModel.story.storyNodes.count else { return }
        currentIndex = index
        appModel.selectedStoryNodeID = appModel.story.storyNodes[index].id
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview{
    PresentationView()
        .backgroundStyle(.background)
        .environment(AppModel())
}
