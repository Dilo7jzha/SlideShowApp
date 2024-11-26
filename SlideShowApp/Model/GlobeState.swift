//
//  GlobeState.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation
import SwiftUI

struct GlobeState: Hashable {
    var position: SIMD3<Float> = [0, 0, 0]
    var focusLatitude = Angle.zero
    var focusLongitude = Angle.zero
    var scale: Float = 1
}
