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
    
    var orientation: simd_quatf? {
#warning("Radius")
        let radius = 0.2
        let globeToCamera: SIMD3<Float> = [0, 0, 1]
        guard let xyz = latLonToXYZ(radius: radius) else { return nil }
        let orientation = simd_quatf(from: normalize(xyz), to: globeToCamera)
#warning("The globe is not generally north-oriented, and the following does not work")
//        return GlobeEntity.orientToNorth(orientation: orientation)
        return orientation
    }
    
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
