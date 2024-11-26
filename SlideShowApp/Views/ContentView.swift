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
    @State private var showImportJSON = false // true when the story points are to be imported from a JSON file
    
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
        .fileImporter(
            isPresented: $showImportJSON,
            allowedContentTypes: [.json],
            onCompletion: { result in
                importJSON(from: result)
            }
        )
        .alert(
            appModel.errorToShowInAlert?.localizedDescription ?? "An error occurred.",
            isPresented: showErrorBinding,
            presenting: appModel.errorToShowInAlert
        ) { _ in
            // default OK button
        } message: { error in
            if let message = error.alertSecondaryMessage {
                Text(message)
            }
        }
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
            Button("Export") {
                showExportJSON.toggle()
            }
            .disabled(appModel.story.isEmpty)
            
            Button("Import") {
                showImportJSON.toggle()
            }
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
    
    private var jsonDocument: JSONDocument? {
        do {
            let jsonData = try JSONEncoder().encode(appModel.story)
            return JSONDocument(json: jsonData)
        } catch {
            appModel.errorToShowInAlert = error
            return nil
        }
    }
    
    private func importJSON(from result: Result<URL, any Error>) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else {
                throw error("Cannot access file.")
            }
            defer { url.stopAccessingSecurityScopedResource() }
            let jsonData = try Data(contentsOf: url)
            appModel.story = try JSONDecoder().decode([StoryPoint].self, from: jsonData)
        } catch {
            appModel.errorToShowInAlert = error
        }
    }
    
    private var showErrorBinding: Binding<Bool> {
        Binding<Bool>(
            get: { appModel.errorToShowInAlert != nil },
            set: {
                if $0 == false {
                    appModel.errorToShowInAlert = nil
                }
            })
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
