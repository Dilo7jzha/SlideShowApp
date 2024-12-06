//
//  ContentView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

#if os(visionOS)
    @State private var editMode = EditMode.inactive
#endif
    
#if os(macOS)
    @Environment(\.openWindow) private var openWindow
#endif
    
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
                if case .failure(let error) = result {
                    appModel.errorToShowInAlert = error
                }
            })
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
        List(selection: Bindable(appModel).selectedStoryPointID) {
            ForEach(appModel.story.storyPoints) { storyPoint in
                Text(storyPoint.name)
            }
            .onDelete { appModel.story.storyPoints.remove(atOffsets: $0) }
            .onMove { appModel.story.storyPoints.move(fromOffsets: $0, toOffset: $1) }
        }
        .listStyle(.sidebar)
        .navigationTitle("Story Points")
        .toolbar {
            Button(action: addStoryPoint) {
                Label("Add Story Point", systemImage: "plus")
            }

#if os(visionOS)
            EditButton()
                .disabled(!appModel.story.hasStoryPoints)
            ToggleImmersiveSpaceButton()
#else
            Button(action: deleteStoryPoint, label: { Label("Delete Story Point", systemImage: "minus") })
                .disabled(appModel.selectedStoryPointID == nil)
            
            Button(action: {
                openWindow(id: AppModel.macOSGlobeViewID)
            }, label: { Label("Globe", systemImage: "globe") })
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
            .disabled(!appModel.story.hasStoryPoints)
            
            Button("Import") {
                showImportJSON.toggle()
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let selectedStoryPointID = appModel.selectedStoryPointID,
           let index = appModel.story.storyPointIndex(for: selectedStoryPointID) {
            StoryPointView(storyPoint: Bindable(appModel).story.storyPoints[index])
        } else {
            let message = appModel.story.hasStoryPoints ? "Select a Story Point" : "Add a Story Point"
            Text(message)
                .font(.title)
                .foregroundColor(.white)
        }
    }

    private func addStoryPoint() {
        let storyPointNumber = appModel.story.numberOfStoryPoints + 1
        let storyPoint = StoryPoint(
            name: "Story Point \(storyPointNumber)",
            slide: Slide(text: "Enter text here"),
            globeState: GlobeState()
        )
        appModel.story.addStoryPoint(storyPoint)
        
        // Set the newly added story point as selected
        Task { @MainActor in
            appModel.selectedStoryPointID = storyPoint.id // select the new story point
        }
        
    #if os(visionOS)
        editMode = .inactive
    #endif
    }
    
    private func deleteStoryPoint() {
        appModel.story.removeStoryPoint(with: appModel.selectedStoryPointID)
        appModel.selectedStoryPointID = nil
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
            appModel.story = try JSONDecoder().decode(Story.self, from: jsonData)
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
