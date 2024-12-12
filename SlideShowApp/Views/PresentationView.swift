import SwiftUI

struct PresentationView: View {
    let storyPoints: [StoryPoint]
    @State private var currentIndex = 0
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            if let currentStoryPoint = storyPoints[safe: currentIndex] {
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
                    if currentIndex > 0 {
                        currentIndex -= 1
                    }
                }
                .disabled(currentIndex <= 0)
                
                Spacer()
                
                Button("Next") {
                    if currentIndex < storyPoints.count - 1 {
                        currentIndex += 1
                    }
                }
                .disabled(currentIndex >= storyPoints.count - 1)
            }
            .padding()

            // Return and End Presentation Buttons
            HStack {
                Button("Return") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Presentation")
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
