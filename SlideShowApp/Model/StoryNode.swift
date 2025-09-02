//
//  StoryNode.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation
import RealityKit

struct StoryNode: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String = "Unnamed Story Node"
    var slide: Slide? = nil
    var globeState: GlobeState? = nil
    var annotationIDs: [UUID] = []
}
