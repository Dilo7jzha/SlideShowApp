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
            if let currentStoryPoint = appModel.story.storyPoints[safe: currentIndex] {
                SlideView(slide: .constant(currentStoryPoint.slide), isEditable: false)
                    .padding()
            } else {
                Text("No slides available")
                    .font(.headline)
                    .padding()
            }

            Spacer() // Pushes buttons towards the bottom

            // Navigation Buttons
            HStack {
                Button(action: { goToStoryPoint(at: currentIndex - 1) }) {
                    Label("Previous", systemImage: "arrow.left")
                        .font(.largeTitle)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(currentIndex <= 0)

                Spacer()

                Button(action: { goToStoryPoint(at: currentIndex + 1) }) {
                    Label("Next", systemImage: "arrow.right")
                        .font(.largeTitle)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(currentIndex >= appModel.story.storyPoints.count - 1)
            }
            .padding()

            // Return Button at the Bottom
            Button(action: { appModel.isPresenting = false }) {
                Text("Return")
                    .font(.largeTitle)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Presentation")
    }

    private func goToStoryPoint(at index: Int) {
        guard index >= 0, index < appModel.story.storyPoints.count else { return }
        currentIndex = index
        appModel.selectedStoryPointID = appModel.story.storyPoints[index].id
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
