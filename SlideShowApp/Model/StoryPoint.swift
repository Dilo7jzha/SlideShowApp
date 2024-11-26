//
//  StoryPoint.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation

struct StoryPoint: Identifiable, Hashable {
    let id = UUID()
    
    var slide: Slide
    var globeState: GlobeState
}
