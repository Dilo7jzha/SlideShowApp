//
//  ContentView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var editMode = EditMode.inactive
    @Environment(AppModel.self) private var appModel
    @State private var selectedStoryPoint: StoryPoint? // Tracks the currently selected StoryPoint
    @State private var showExportJSON = false // true when the story points are to be exported to a JSON file
    
    var body: some View {
        NavigationSplitView {
            navigationView
            footerView
        } detail: {
            detailView
        }
        .fileExporter(
            isPresented: $showExportJSON,
            document: jsonDocument,
            contentType: .json,
            defaultFilename: "Story Points",
            onCompletion: { result in
                print(result)
            }
        )
    }
    
    @ViewBuilder
    private var navigationView: some View {
        List(selection: $selectedStoryPoint) {
            ForEach(appModel.story) { storyPoint in
                NavigationLink(storyPoint.name, value: storyPoint)
            }
            .onDelete { appModel.story.remove(atOffsets: $0) }
            .onMove { appModel.story.move(fromOffsets: $0, toOffset: $1) }
        }
        .listStyle(.sidebar)
        .navigationTitle("Story Points")
        .toolbar {
            EditButton()
                .disabled(appModel.story.isEmpty)
                .labelStyle(.iconOnly)
            Button(action: addStoryPoint) {
                Label("Add Story Point", systemImage: "plus")
            }
        }
        .environment(\.editMode, $editMode)
    }
    
    @ViewBuilder
    private var footerView: some View {
        HStack {
            Button("Export JSON") {
                showExportJSON.toggle()
            }
            .disabled(appModel.story.isEmpty)
        }
        .padding()
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let selectedStoryPoint,
           let index = appModel.story.firstIndex(where: { $0.id == selectedStoryPoint.id }) {
            StoryPointView(storyPoint: Bindable(appModel).story[index])
        } else {
            let message = appModel.story.isEmpty ? "Add a Story Point" : "Select a Story Point"
            Text(message)
                .font(.title)
                .foregroundColor(.white)
        }
    }
    
    private func addStoryPoint() {
        let globeState = GlobeState(
            position: [0, 0, 0],
            focusLatitude: Angle(degrees: 47),
            focusLongitude: Angle(degrees: 8),
            scale: 1
        )
        let storyPointNumber = appModel.story.count + 1
        let storyPoint = StoryPoint(
            name: "Story Point \(storyPointNumber)",
            slide: Slide(text: "Enter text here"),
            globeState: globeState
        )
        appModel.story.append(storyPoint)
        editMode = .inactive
        Task { @MainActor in
            selectedStoryPoint = storyPoint // select the new story point
        }
    }
    
    var jsonDocument: JSONDocument? {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(appModel.story)
            return JSONDocument(json: jsonData)
        } catch {
#warning("Need proper error handling")
            print(error)
            return nil
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
