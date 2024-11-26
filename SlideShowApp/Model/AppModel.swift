//
//  AppModel.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI

@MainActor
@Observable
class AppModel {
    var story: [StoryPoint] = []
}

extension AppModel {
    static var preview: AppModel {
        let appModel = AppModel()
        let globeState = GlobeState(position: [0, 0, 0], focusLatitude: Angle(degrees: 47), focusLongitude: Angle(degrees: 8), scale: 1)
        appModel.story.append(StoryPoint(slide: Slide(text: "Start"), globeState: globeState))
        appModel.story.append(StoryPoint(slide: Slide(text: "End"), globeState: globeState))
        return appModel
    }
}
