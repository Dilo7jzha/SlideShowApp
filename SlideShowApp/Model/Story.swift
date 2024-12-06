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
}
