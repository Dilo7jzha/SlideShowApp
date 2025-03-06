//
//  StoryPointView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI

struct StoryPointView: View {
    @Binding var storyPoint: StoryPoint
    @Binding var story: Story // Now accessing the story to manage annotations
    var applyState: () -> Void
    @State private var selectedTab = 0
    @State private var showAnnotationsView = false
    @State private var showNamePanel: Bool = false
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Label("Slide", systemImage: "text.below.photo").tag(0)
                Label("Globe Attributes", systemImage: "globe").tag(1)
                Label("Annotations", systemImage: "pin").tag(2) //Annotations tab
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            .padding()
            
            switch selectedTab {
            case 0:
                SlideView(slide: $storyPoint.slide)
                    .padding()
            case 1:
                if let globeState = Binding($storyPoint.globeState) {
                    GlobeStateView(globeState: globeState, applyState: applyState)
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
        .navigationTitle(storyPoint.name)
        .toolbar {
            Button("Edit Name", systemImage: "pencil") {
                showNamePanel.toggle()
            }
        }
        .sheet(isPresented: $showNamePanel) {
            VStack {
                Text("Story Point Name")
                    .font(.title)
                
                TextField(text: $storyPoint.name, prompt: Text("Name"), label: {
                    Text("Story Point Name")
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
            Section("Select Annotations by ID") {
                ForEach(story.annotations) { annotation in
                    Toggle(isOn: annotationSelectionBinding(for: annotation.id)) {
                        VStack(alignment: .leading) {
                            Text("ID: \(annotation.id.uuidString.prefix(8))") // Display annotation ID
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
            get: { storyPoint.annotationIDs.contains(id) },
            set: { newValue in
                if newValue {
                    storyPoint.annotationIDs.append(id)
                } else {
                    storyPoint.annotationIDs.removeAll { $0 == id }
                }
            }
        )
    }
}

#Preview {
    StoryPointView(
        storyPoint: .constant(StoryPoint(slide: Slide(), globeState: GlobeState(), annotationIDs: [])),
        story: .constant(Story(storyPoints: [], annotations: [Annotation(latitude: Angle(degrees: 0), longitude: Angle(degrees: 0), offset: 0, text: "Sample Annotation")])),
        applyState: {}
    )
}

