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
    var story: [StoryPoint] = []
    var errorToShowInAlert: Error? = nil {
        didSet {
            if let errorToShowInAlert {
                let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Globes Error")
                logger.error("Alert: \(errorToShowInAlert.localizedDescription) \(errorToShowInAlert.alertSecondaryMessage ?? "")")
            }
        }
    }
}

extension AppModel {
    static var preview: AppModel {
        let appModel = AppModel()
        let globeState = GlobeState(position: [0, 0, 0], focusLatitude: Angle(degrees: 47), focusLongitude: Angle(degrees: 8), scale: 1)
        appModel.story.append(StoryPoint(name: "Start", slide: Slide(text: "Start"), globeState: globeState))
        appModel.story.append(StoryPoint(name: "End", slide: Slide(text: "End"), globeState: globeState))
        return appModel
    }
}
