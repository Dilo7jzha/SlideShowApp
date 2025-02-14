//
//  SphericalCoordinates.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 14/2/2025.
//

import SwiftUI

struct SphericalCoordinates {
    private init() {}
    
    static func xyzToLatLon(xyz: SIMD3<Float>) -> (latitude: Angle, longitude: Angle) {
        let x = Double(xyz.z)
        let y = Double(xyz.x)
        let z = Double(xyz.y)
        
        let r = sqrt(x * x + y * y + z * z)
        let lat = .pi / 2 - acos(z / r)
        let lon = atan2(y, x) + .pi / 2
        
        return (Angle(radians: lat), Angle(radians: lon))
    }
    
    static func latLonToXYZ(latitude: Angle, longitude: Angle, radius: Double) -> SIMD3<Float> {
        let lat = latitude.radians
        let lon = longitude.radians - .pi / 2
        
        let x = radius * cos(lat) * cos(lon)
        let y = radius * cos(lat) * sin(lon)
        let z = radius * sin(lat)
        
        return SIMD3<Float>(Float(y), Float(z), Float(x))
    }
}
