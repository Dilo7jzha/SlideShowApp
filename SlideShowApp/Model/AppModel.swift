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
    
    var story = Story()
    
    /// The ID of the currently selected StoryPoint.
    var selectedStoryPointID: StoryPoint.ID?
    
    /// The currently selected StoryPoint.
    var selectedStoryPoint: StoryPoint? {
        story.storyPoint(with: selectedStoryPointID)
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
