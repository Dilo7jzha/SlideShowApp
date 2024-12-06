//
//  GlobeState.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import Foundation
import RealityKit
import SwiftUI

struct GlobeState: Hashable, Codable {
    var position: SIMD3<Float>? = nil
    var focusLatitude: Angle? = nil
    var focusLongitude: Angle? = nil
    var scale: Float? = nil
    
    static func xyzToLatLon(xyz: SIMD3<Float>) -> (latitude: Angle, longitude: Angle) {
        let x = Double(xyz.z)
        let y = Double(xyz.x)
        let z = Double(xyz.y)
        
        let r = sqrt(x * x + y * y + z * z)
        let lat = .pi / 2 - acos(z / r)
        let lon = atan2(y, x) + .pi / 2
        
        return (Angle(radians: lat), Angle(radians: lon))
    }

    func latLonToXYZ(radius: Double) -> SIMD3<Float>? {
        guard let focusLatitude, let focusLongitude else { return nil }
        
        let lat = focusLatitude.radians
        let lon = focusLongitude.radians - .pi / 2 // Adjust longitude to match xyzToLatLon

        let x = radius * cos(lat) * cos(lon)
        let y = radius * cos(lat) * sin(lon)
        let z = radius * sin(lat)

        // Note: We swap y and z to match the coordinate system in xyzToLatLon
        return SIMD3<Float>(Float(y), Float(z), Float(x))
    }
}
