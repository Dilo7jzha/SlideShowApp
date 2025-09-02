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

    var storyNodes: [StoryNode] = []
    var annotations: [Annotation] = []
    
    var hasStoryNodes: Bool {
        !storyNodes.isEmpty
    }
    
    func storyNode(with id: StoryNode.ID?) -> StoryNode? {
        storyNodes.first(where: { $0.id == id })
    }
    
    func storyNodeIndex(for id: StoryNode.ID?) -> Array.Index? {
        storyNodes.firstIndex(where: { $0.id == id })
    }
    
    var numberOfStoryNodes: Int {
        storyNodes.count
    }
    
    mutating func removeStoryNode(with id: StoryNode.ID?) {
        storyNodes.removeAll(where: { $0.id == id })
    }
    
    mutating func addStoryNode(_ storyNode: StoryNode) {
        storyNodes.append(storyNode)
    }
    
    /// Find the GlobeState created by the n first story nodes, where n is the index of the  story node with a given ID.
    /// - Parameter lastStoryNodeID: ID of the StoryNode for which the accumulated GlobeState is returned.
    /// - Returns: GlobeState
    func accumulatedGlobeState(for lastStoryNodeID: StoryNode.ID?) throws -> GlobeState {
        guard storyNode(with: lastStoryNodeID) != nil else {
            throw error("StoryNode not found.")
        }
        var state = GlobeState(
            position: [0, 0, 0],
            focusLatitude: .zero,
            focusLongitude: .zero,
            scale: 1
        )
        for storyNode in storyNodes {
            if let position = storyNode.globeState?.position {
                state.position = position
            }
            if let scale = storyNode.globeState?.scale {
                state.scale = scale
            }
            if let focusLatitude = storyNode.globeState?.focusLatitude {
                state.focusLatitude = focusLatitude
            }
            if let focusLongitude = storyNode.globeState?.focusLongitude {
                state.focusLongitude = focusLongitude
            }
            
            if storyNode.id == lastStoryNodeID {
                break
            }
        }
        return state
    }
}
