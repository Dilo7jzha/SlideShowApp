//
//  StoryNodeView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI

struct StoryNodeView: View {
    @Binding var storyNode: StoryNode
    @Binding var story: Story
    @State private var selectedTab = 0
    @State private var showAnnotationsView = false
    @State private var showNamePanel: Bool = false
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Label("Slide", systemImage: "text.below.photo").tag(0)
                Label("Globe", systemImage: "globe").tag(1)
                Label("Info Panel", systemImage: "pin").tag(2) //Annotations tab
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            .padding()
            
            switch selectedTab {
            case 0:
                SlideView(slide: $storyNode.slide)
                    .padding()
                    .padding(.horizontal)
            case 1:
                if let globeState = Binding($storyNode.globeState) {
                    GlobeStateView(globeState: globeState)
                        .padding()
                } else {
                    Text("No globe state available.")
                        .foregroundStyle(.red)
                        .padding()
                }
            case 2:
                annotationSelectionView() // Annotations section
                    .padding()
            default:
                EmptyView()
            }
            
            Spacer(minLength: 0)
        }
        .navigationTitle(storyNode.name)
        .toolbar {
            Button("Edit Name", systemImage: "pencil") {
                showNamePanel.toggle()
            }
        }
        .sheet(isPresented: $showNamePanel) {
            VStack {
                Text("Story Node Name")
                    .font(.title)
                
                TextField(text: $storyNode.name, prompt: Text("Name"), label: {
                    Text("Story Node Name")
                })
                .textFieldStyle(.roundedBorder)
                .padding()
                
                Button("Close") {
                    showNamePanel = false
                }
            }
            .padding()
        }
    }
    
    // Annotation selection UI
    private func annotationSelectionView() -> some View {
        Form {
            Section("Select Annotations by Name") {
                ForEach(story.annotations) { annotation in
                    Toggle(isOn: annotationSelectionBinding(for: annotation.id)) {
                        VStack(alignment: .leading) {
                            Text(annotation.text)
                                .bold()
                        }
                    }
                }
            }

            Section {
                Button(action: {
                    showAnnotationsView.toggle()
                }) {
                    Label("Manage Annotations", systemImage: "plus.viewfinder")
                }
                .sheet(isPresented: $showAnnotationsView) {
                    AnnotationsView(story: $story, isPresented: $showAnnotationsView)
                }
            }
        }
    }

    
    // id binding to track selected annotations
    private func annotationSelectionBinding(for id: UUID) -> Binding<Bool> {
        Binding<Bool>(
            get: { storyNode.annotationIDs.contains(id) },
            set: { newValue in
                if newValue {
                    storyNode.annotationIDs.append(id)
                } else {
                    storyNode.annotationIDs.removeAll { $0 == id }
                }
            }
        )
    }
}

#Preview {
    StoryNodeView(
        storyNode: .constant(StoryNode(slide: Slide(), globeState: GlobeState(), annotationIDs: [])),
        story: .constant(Story(storyNodes: [], annotations: [Annotation(latitude: Angle(degrees: 0), longitude: Angle(degrees: 0), offset: 0, text: "Sample Annotation")]))
    )
}

