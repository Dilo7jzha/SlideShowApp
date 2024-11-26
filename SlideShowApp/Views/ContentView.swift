//
//  ContentView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @State private var selectedStoryPoint: StoryPoint? // Tracks the currently selected StoryPoint

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedStoryPoint) {
                ForEach(appModel.story) { storyPoint in
                    NavigationLink(storyPoint.slide.text, value: storyPoint)
                }
                .onDelete { appModel.story.remove(atOffsets: $0) }
                .onMove { appModel.story.move(fromOffsets: $0, toOffset: $1) }
            }
            .listStyle(.sidebar)
            .navigationTitle("Story Points")
            .toolbar {
                EditButton()
                    .disabled(appModel.story.isEmpty)
                Button(action: addStoryPoint) {
                    Label("Add Story Point", systemImage: "plus")
                }
            }
        } detail: {
            Text(selectedStoryPoint?.slide.text ?? "")
            if let selectedStoryPoint,
                let index = appModel.story.firstIndex(where: { $0.id == selectedStoryPoint.id }) {
                SlideDetailView(slide: Bindable(appModel).story[index].slide) // Show slide content for editing
            } else {
                Text("Select a Slide")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }

    func addStoryPoint() {
        let globeState = GlobeState(position: [0, 0, 0], focusLatitude: Angle(degrees: 47), focusLongitude: Angle(degrees: 8), scale: 1)
        let storyPoint = StoryPoint(slide: Slide(text: "Unnamed Story Point"), globeState: globeState)
        appModel.story.append(storyPoint)
        selectedStoryPoint = storyPoint // select the new story point
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}