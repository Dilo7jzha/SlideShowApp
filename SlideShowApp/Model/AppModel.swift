//
//  AppModel.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import os
import SwiftUI

@MainActor
@Observable
class AppModel {
    
    // MARK: - Globe
    
    var globe = Globe(name: "Demo", radius: 0.2, texture: "globe_texture")
    
    // MARK: - Story
    
    var story: [StoryPoint] = []
    
    /// The ID of the currently selected StoryPoint.
    var selectedStoryPointID: StoryPoint.ID?
    
    /// The currently selected StoryPoint.
    var selectedStoryPoint: StoryPoint? {
        story.first(where: { $0.id == selectedStoryPointID })
    }

    // MARK: - Error Handling
    
    var errorToShowInAlert: Error? = nil {
        didSet {
            if let errorToShowInAlert {
                let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Globes Error")
                logger.error("Alert: \(errorToShowInAlert.localizedDescription) \(errorToShowInAlert.alertSecondaryMessage ?? "")")
            }
        }
    }
    
    // MARK: - Immersive Space
    
#if os(visionOS)
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
#else
    static let macOSGlobeViewID = "macOSGlobeView"
#endif
}

// MARK: - Preview

extension AppModel {
    static var preview: AppModel {
        let appModel = AppModel()
        let globeState = GlobeState(position: [0, 0, 0], focusLatitude: Angle(degrees: 47), focusLongitude: Angle(degrees: 8), scale: 1)
        appModel.story.append(StoryPoint(name: "Start", slide: Slide(text: "Start"), globeState: globeState))
        appModel.story.append(StoryPoint(name: "End", slide: Slide(text: "End"), globeState: globeState))
        return appModel
    }
}
