//
//  Annotation.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 29/1/2025.
//

import Foundation
import RealityKit
import SwiftUI

struct Annotation: Identifiable, Codable, Hashable {
    var id = UUID()
    
    var latitude: Angle
    var longitude: Angle
    
    /// Offset from the globe surface
    var offset: Float = 0.03
    
    /// Annotation text
    var text: String

    /// Entity to place on globe, loaded from app bundle
    var entityName: String? = "Pin_V2"
    
    /// Convert annotation to XYZ for rendering
    func positionOnGlobe(radius: Float) -> SIMD3<Float> {
        SphericalCoordinates.latLonToXYZ(latitude: latitude, longitude: longitude, radius: Double(radius))
    }
    
    func orientation(for position: SIMD3<Float>) -> simd_quatf {
        // rotate up vector to the location on the sphere
        let normalVector = normalize(position)
        let rotationToPosition = simd_quaternion([0, 1, 0], normalVector)
        
        // rotation around the up-axis of the entity to orient it parallel to the equator
        let rotationToParallel = simd_quatf(angle: Float(longitude.radians), axis: [0, 1, 0])
        
        return rotationToPosition * rotationToParallel
    }
}
