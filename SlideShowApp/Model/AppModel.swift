//
//  AppModel.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import os
import SwiftUI
import RealityKit

@MainActor
@Observable
class AppModel {
    
    // MARK: - Globe
    
    var globe = Globe(name: "Demo", radius: 0.2, texture: "globe_texture")
    var globeEntity: GlobeEntity? // Parent (handles gestures)

    // MARK: - Story

    var story = Story()

    var configuration = GlobeConfiguration()
    var georeferencer = Georeferencer()

    var isPresenting: Bool = false

    /// The ID of the currently selected StoryNode.
    var selectedStoryNodeID: StoryNode.ID?
    
    var selectedStoryNode: StoryNode? {
        story.storyNodes.first(where: { $0.id == selectedStoryNodeID })
    }
    
    func selectFirstStoryNode() {
        selectedStoryNodeID = story.storyNodes.first?.id
    }

    struct GlobeConfiguration {
        var minScale: Float = 0.5
        var maxScale: Float = 2.0
        var isRotationPaused: Bool = false
        var showAttachment: Bool = false
    }

    // MARK: - Image Viewer Window Management
    
    var currentImageForViewer: CodableImage? = nil
    var isImageViewerOpen: Bool = false // Track if image viewer is currently open
    
    #if os(macOS)
    static let imageViewerWindowID = "ImageViewerWindow"
    #endif

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
    static let immersiveSpaceID = "ImmersiveSpace"

    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed

    func openImmersiveSpace(with openAction: OpenImmersiveSpaceAction) async {
        guard immersiveSpaceState != .open,
              immersiveSpaceState != .inTransition else {
            return
        }

        immersiveSpaceState = .inTransition

        switch await openAction(id: Self.immersiveSpaceID) {
        case .opened:
            break
        case .userCancelled:
            immersiveSpaceState = .closed
        case .error:
            errorToShowInAlert = error("An immersive space failed to open.")
            fallthrough
        @unknown default:
            immersiveSpaceState = .closed
        }
    }

    func dismissImmersiveSpace(with dismissAction: DismissImmersiveSpaceAction) async {
        guard immersiveSpaceState == .open else { return }
        await dismissAction()
        immersiveSpaceState = .closed
    }
#endif

#if os(macOS) || os(iOS)
    static let macOSGlobeViewID = "macOSGlobeView"
#endif
}
