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
    
    var body: some View {
        VStack {
            Picker("What is your favorite color?", selection: $selectedTab) {
                Label("Slide", systemImage: "text.below.photo").tag(0)
                Label("Globe", systemImage: "globe").tag(1)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            
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
    }
}

#Preview {
    StoryPointView(storyPoint: .constant(StoryPoint(slide: Slide())))
}
