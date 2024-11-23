//
//  Slide.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

struct Slide: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var image: UIImage?
}
