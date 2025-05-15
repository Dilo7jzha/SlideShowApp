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
    
    /// Offset from the globe surface for the text label
    var offset: Float = 0.03
    
    /// Offset from the globe surface for 3D models
    var modelOffset: Float = 0.015
    
    /// Annotation text (title)
    var text: String
    
    /// Annotation description (shown when expanded)
    var description: String = ""
    
    /// Image names for the annotation (shown when expanded)
    var imageNames: [String] = []

    /// Entity to place on globe, loaded from app bundle
    var entityName: String? = "Pin_V2"

    var usdzFileName: String?
    var usdzFileURL: URL?
    
    /// Convert annotation to XYZ for rendering
    func positionOnGlobe(radius: Float) -> SIMD3<Float> {
        SphericalCoordinates.latLonToXYZ(latitude: latitude, longitude: longitude, radius: Double(radius))
    }
    
    /// Get position with additional offset for 3D models
    func modelPositionOnGlobe(radius: Float) -> SIMD3<Float> {
        let basePosition = positionOnGlobe(radius: radius)
        let normalVector = normalize(basePosition)
        return basePosition + normalVector * modelOffset
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
