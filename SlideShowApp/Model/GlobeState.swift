//
//  GlobeState.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation
import SwiftUI

struct GlobeState {
    var position: SIMD3<Float>
    var focusLatitude: Angle
    var focusLongitude: Angle
    var scale: Float
}
