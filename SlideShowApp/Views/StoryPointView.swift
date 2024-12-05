//
//  StoryPointView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI

struct StoryPointView: View {
    @Binding var storyPoint: StoryPoint
    @State private var selectedTab = 0
    @State private var showNamePanel: Bool = false

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Label("Slide", systemImage: "text.below.photo").tag(0)
                Label("Globe Attributes", systemImage: "globe").tag(1)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            .padding()

            switch selectedTab {
            case 0:
                SlideView(slide: $storyPoint.slide)
                    .padding()
            case 1:
                GlobeStateView(globeState: $storyPoint.globeState)
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
}



#Preview {
    StoryPointView(storyPoint: .constant(StoryPoint(slide: Slide())))
}
