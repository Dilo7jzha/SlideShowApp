//
//  ContentView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.editMode) private var editMode
    @State private var showExportJSON = false
    @State private var showImportJSON = false
    
    var body: some View {
        Group{
            if appModel.isPresenting {
                PresentationView()
            } else {
                editView
            }
        }
        .fileExporter(
            isPresented: $showExportJSON,
            document: jsonDocument,
            contentType: .json,
            defaultFilename: "Story",
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
    private var editView: some View {
            NavigationSplitView {
                ZStack {
                    navigationView
                    VStack {
                        Spacer()
                        footerView
                            .controlSize(.large)
                            .padding(.top)
                            .padding(.bottom, 24)
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea()
                            .background(.ultraThickMaterial)
                    }
                }
                .navigationSplitViewColumnWidth(350)
                .background(.thickMaterial)
            } detail: {
                detailView
        }
    }
    
    @ViewBuilder
    private var navigationView: some View {
        List(selection: Bindable(appModel).selectedStoryNodeID) {
            ForEach(appModel.story.storyNodes) {
                Text($0.name)
            }
            .onDelete {
                appModel.story.storyNodes.remove(atOffsets: $0)
                if appModel.story.storyNodes.isEmpty {
                    editMode?.wrappedValue = .inactive
                }
            }
            .onMove { appModel.story.storyNodes.move(fromOffsets: $0, toOffset: $1) }
        }
        .listStyle(.sidebar)
        .navigationTitle("Story Nodes")
        .toolbar {
            Button(action: addStoryNode) {
                Label("Add Story Node", systemImage: "plus")
            }
            
            EditButton()
                .disabled(!appModel.story.hasStoryNodes)
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        HStack(spacing: 24) {
            Menu {
                Button("Export Story") {
                    showExportJSON.toggle()
                }
                .disabled(!appModel.story.hasStoryNodes)
                
                Button("Import Story") {
                    showImportJSON.toggle()
                }
            } label: {
                Label("Story File", systemImage: "doc")
                
            }
            
            ToggleImmersiveSpaceButton()
            
            Button(action: {
                if appModel.selectedStoryNodeID == nil {
                    appModel.selectFirstStoryNode()
                }
                appModel.isPresenting.toggle()
            }) {
                Label("Story File", systemImage: "play.circle")
                    .imageScale(.large)
            }
            .disabled(!appModel.story.hasStoryNodes)
        }
        .labelStyle(.iconOnly)
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let selectedStoryNodeID = appModel.selectedStoryNodeID,
           let index = appModel.story.storyNodeIndex(for: selectedStoryNodeID) {
            StoryNodeView(story: Bindable(appModel).story,
                          storyNode: Bindable(appModel).story.storyNodes[index])
        } else {
            let message = appModel.story.hasStoryNodes ? "Select a story node or press the play button." : "Add a Story Node"
            ContentUnavailableView {
                Label(message, systemImage: "plus")
                    .labelStyle(.titleOnly)
            }
        }
    }
    
    private func addStoryNode() {
        let storyNodeNumber = appModel.story.numberOfStoryNodes + 1
        let storyNode = StoryNode(
            name: "Story Node \(storyNodeNumber)",
            slide: Slide(text: "Enter text here"),
            globeState: GlobeState()
        )
        appModel.story.addStoryNode(storyNode)
        
        // Set the newly added story node as selected
        Task { @MainActor in
            appModel.selectedStoryNodeID = storyNode.id // select the new story node
        }
        
        editMode?.wrappedValue = .inactive
    }
    
    private func deleteStoryNode() {
        appModel.story.removeStoryNode(with: appModel.selectedStoryNodeID)
        appModel.selectedStoryNodeID = nil
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
