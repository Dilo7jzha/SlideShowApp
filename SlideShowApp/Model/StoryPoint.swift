//
//  StoryPoint.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation
import RealityKit

struct StoryPoint: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String = "Unnamed Story Point"
    var slide: Slide? = nil
    var globeState: GlobeState? = nil
}
