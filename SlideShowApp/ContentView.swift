//
//  ContentView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var slides: [Slide] = []
    @State private var selectedSlide: Slide? // Tracks the currently selected slide

    var body: some View {
        NavigationSplitView {
            VStack {
                List {
                    ForEach(slides) { slide in
                        Button(action: {
                            selectedSlide = slide
                        }) {
                            HStack {
                                Text(slide.text)
                                    .lineLimit(1)
                                    .font(.headline)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Makes it look like a list item
                        .padding(.vertical, 4)
                        .background(selectedSlide?.id == slide.id ? Color.gray.opacity(0.2) : Color.clear) // Highlight selected
                        .cornerRadius(8)
                    }
                    .onMove(perform: moveSlide)
                }
                .navigationTitle("Slides")
                .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton() // Enables drag-and-drop mode
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: addNewSlide) {
                                Label("Add Slide", systemImage: "plus")
                            }
                        }
                    }
                }
        } detail: {
            if let selectedSlide = selectedSlide, let index = slides.firstIndex(where: { $0.id == selectedSlide.id }) {
                SlideDetailView(slide: $slides[index]) // Show slide content for editing
            } else {
                Text("Select a Slide")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }

    func addNewSlide() {
        let newSlide = Slide(text: "New Slide", image: nil)
        slides.append(newSlide)
        selectedSlide = newSlide // Automatically select the new slide
    }
    
    func moveSlide(from source: IndexSet, to destination: Int) {
        slides.move(fromOffsets: source, toOffset: destination)
    }

}



#Preview(windowStyle: .automatic) {
    ContentView()
}
