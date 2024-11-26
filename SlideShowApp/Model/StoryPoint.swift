//
//  StoryPoint.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation

struct StoryPoint: Identifiable, Hashable {
    let id = UUID()
    var name: String = "Unnamed Story Point"
    var slide: Slide? = nil
    var globeState: GlobeState? = nil
}
