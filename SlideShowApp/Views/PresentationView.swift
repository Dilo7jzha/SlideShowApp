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

            // Navigation Buttons
            HStack {
                Button("Previous") {
                    goToStoryPoint(at: currentIndex - 1)
                }
                .disabled(currentIndex <= 0)
                
                Spacer()
                
                Button("Next") {
                    goToStoryPoint(at: currentIndex + 1)
                }
                .disabled(currentIndex >= appModel.story.storyPoints.count - 1)
            }
            .padding()

            // Return and End Presentation Buttons
            HStack {
                Button("Return") {
                    appModel.isPresenting = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
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
