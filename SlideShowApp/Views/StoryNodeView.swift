//
//  StoryNodeView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI

struct StoryNodeView: View {
    @Binding var story: Story
    @Binding var storyNode: StoryNode
    
    @State private var selectedTab = 0
    @State private var showInfoPanelsList = false
    @State private var showEditInfoPanelSheet = false
    @State private var showNamePanel: Bool = false
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Label("Slide", systemImage: "text.below.photo").tag(0)
                Label("Globe", systemImage: "globe").tag(1)
                Label("Info Panel", systemImage: "pin").tag(2) //Annotations tab
            }
            .pickerStyle(.segmented)
            .labelStyle(.titleAndIcon)
            .frame(maxWidth: 400)
            .padding()
            
            Group {
                switch selectedTab {
                case 0:
                    SlideEditView(slide: $storyNode.slide)
                        .padding(.horizontal)
                case 1:
                    if let globeState = Binding($storyNode.globeState) {
                        GlobeStateView(globeState: globeState)
                    } else {
                        Text("No globe state available.")
                            .foregroundStyle(.red)
                    }
                case 2:
                    InfoPanelView(story: $story, storyNode: $storyNode)
                default:
                    EmptyView()
                }
            }
            .padding()
            
            Spacer(minLength: 0)
        }
        .navigationTitle(storyNode.name)
        .toolbar {
            Button("Edit Name of Story Node", systemImage: "pencil") {
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
}
