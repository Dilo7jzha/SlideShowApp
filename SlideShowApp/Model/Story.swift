//
//  Story.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 6/12/2024.
//

import Foundation

struct Story: Identifiable, Codable, Hashable {
    var id = UUID()

    var name = "Unnamed Story"

    var storyPoints: [StoryPoint] = []
    
    var hasStoryPoints: Bool {
        !storyPoints.isEmpty
    }
    
    func storyPoint(with id: StoryPoint.ID?) -> StoryPoint? {
        storyPoints.first(where: { $0.id == id })
    }
    
    func storyPointIndex(for id: StoryPoint.ID?) -> Array.Index? {
        storyPoints.firstIndex(where: { $0.id == id })
    }
    
    var numberOfStoryPoints: Int {
        storyPoints.count
    }
    
    mutating func removeStoryPoint(with id: StoryPoint.ID?) {
        storyPoints.removeAll(where: { $0.id == id })
    }
    
    mutating func addStoryPoint(_ storyPoint: StoryPoint) {
        storyPoints.append(storyPoint)
    }
    
    /// Find the GlobeState created by the n first story points, where n is the index of the  story point with a given ID.
    /// - Parameter lastStoryPointID: ID of the StoryPoint for which the accumulated GlobeState is returned.
    /// - Returns: GlobeState
    func accumulatedGlobeState(for lastStoryPointID: StoryPoint.ID?) throws -> GlobeState {
        guard storyPoint(with: lastStoryPointID) != nil else {
            throw error("StoryPoint not found.")
        }
        var state = GlobeState(
            position: [0, 0, 0],
            focusLatitude: .zero,
            focusLongitude: .zero,
            scale: 1,
            annotations: []
        )
        for storyPoint in storyPoints {
            if let position = storyPoint.globeState?.position {
                state.position = position
            }
            if let scale = storyPoint.globeState?.scale {
                state.scale = scale
            }
            if let focusLatitude = storyPoint.globeState?.focusLatitude {
                state.focusLatitude = focusLatitude
            }
            if let focusLongitude = storyPoint.globeState?.focusLongitude {
                state.focusLongitude = focusLongitude
            }
            if let annotations = storyPoint.globeState?.annotations {
                state.annotations = annotations
            }
            if storyPoint.id == lastStoryPointID {
                break
            }            
        }
        return state
    }
}
