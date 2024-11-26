//
//  Slide.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import Foundation

struct Slide: Hashable, Codable {
    var text: String = "Text"
    var image: CodableImage? = nil
}
