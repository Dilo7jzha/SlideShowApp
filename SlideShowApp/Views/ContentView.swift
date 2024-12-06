//
//  ContentView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

struct ContentView: View {
#if os(visionOS)
    @State private var editMode = EditMode.inactive
#endif
    
    @Environment(AppModel.self) private var appModel
    @State private var showExportJSON = false // true when the story points are to be exported to a JSON file
    @State private var showImportJSON = false // true when the story points are to be imported from a JSON file
    @State private var showGlobe = false // Toggles the visibility of the globe view
    
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
        List(selection: Bindable(appModel).selectedStoryPoint) {
            ForEach(appModel.story) { storyPoint in
                NavigationLink(storyPoint.name, value: storyPoint)
            }
            .onDelete { appModel.story.remove(atOffsets: $0) }
            .onMove { appModel.story.move(fromOffsets: $0, toOffset: $1) }
        }
        .listStyle(.sidebar)
        .navigationTitle("Story Points")
        .toolbar {
            
            Button(action: addStoryPoint) {
                Label("Add Story Point", systemImage: "plus")
            }

#if os(visionOS)
            EditButton()
                .disabled(appModel.story.isEmpty)
#else
            Button(action: deleteStoryPoint, label: { Label("Delete Story Point", systemImage: "minus")})
                .disabled(appModel.selectedStoryPoint == nil)
#endif
            
#if os(visionOS)
            ToggleImmersiveSpaceButton()
#else
            Button(action: { showGlobe.toggle() }) {
                Label(showGlobe ? "Hide Globe" : "Show Globe", systemImage: "globe")
                    .disabled(appModel.story.isEmpty)
            }
#endif
        }
#if os(visionOS)
        .environment(\.editMode, $editMode)
#endif
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
#warning("Work in progress")        
//        if showGlobe, let selectedStoryPoint = appModel.selectedStoryPoint {
//            // Pass the globeState directly as optional
//            GlobeView(globeState: selectedStoryPoint.globeState)
//        } else
        if let selectedStoryPoint = appModel.selectedStoryPoint,
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
        let storyPointNumber = appModel.story.count + 1
        let storyPoint = StoryPoint(
            name: "Story Point \(storyPointNumber)",
            slide: Slide(text: "Enter text here"),
            globeState: GlobeState()
        )
        appModel.story.append(storyPoint)
        
        // Set the newly added story point as selected
        Task { @MainActor in
            appModel.selectedStoryPoint = storyPoint // select the new story point
        }
        
    #if os(visionOS)
        editMode = .inactive
    #endif
    }
    
    private func deleteStoryPoint() {
        if let selectedStoryPoint = appModel.selectedStoryPoint {
            appModel.story.removeAll(where: { $0.id == selectedStoryPoint.id })
            appModel.selectedStoryPoint = nil
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

#Preview {
    ContentView()
        .environment(AppModel())
}
