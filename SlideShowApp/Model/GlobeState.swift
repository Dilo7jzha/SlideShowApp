//
//  GlobeState.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation
import SwiftUI

struct GlobeState: Hashable, Codable {
    var position: SIMD3<Float>? = nil
    var focusLatitude: Angle? = nil
    var focusLongitude: Angle? = nil
    var scale: Float? = nil
}
