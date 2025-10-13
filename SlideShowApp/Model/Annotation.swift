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
    
    // MARK: - Codable
    
    /// Custom encoding and decoding for compatibility with vision 2: visionOS 26 changed the JSON encoding format of the `Angle` struct.
    enum CodingKeys: String, CodingKey {
        case id
        case latitudeDegrees
        case longitudeDegrees
        case offset
        case modelOffset
        case text
        case description
        case imageNames
        case entityName
        case usdzFileName
        case usdzFileURL
    }

    init(id: UUID = UUID(),
         latitude: Angle,
         longitude: Angle,
         offset: Float = 0.03,
         modelOffset: Float = 0.015,
         text: String,
         description: String = "",
         imageNames: [String] = [],
         entityName: String? = "Pin_V2",
         usdzFileName: String? = nil,
         usdzFileURL: URL? = nil) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.offset = offset
        self.modelOffset = modelOffset
        self.text = text
        self.description = description
        self.imageNames = imageNames
        self.entityName = entityName
        self.usdzFileName = usdzFileName
        self.usdzFileURL = usdzFileURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()

        // dictionary format of visionOS 2
        let latDict = try container.decodeIfPresent([String: Double].self, forKey: .latitudeDegrees)
        let lonDict = try container.decodeIfPresent([String: Double].self, forKey: .longitudeDegrees)
        if let latDegrees = latDict?["degrees"] {
            latitude = .degrees(latDegrees)
        } else {
            latitude = .zero
        }
        if let lonDegrees = lonDict?["degrees"] {
            longitude = .degrees(lonDegrees)
        } else {
            longitude = .zero
        }

        self.offset = try container.decodeIfPresent(Float.self, forKey: .offset) ?? 0.03
        self.modelOffset = try container.decodeIfPresent(Float.self, forKey: .modelOffset) ?? 0.015
        self.text = try container.decode(String.self, forKey: .text)
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.imageNames = try container.decodeIfPresent([String].self, forKey: .imageNames) ?? []
        self.entityName = try container.decodeIfPresent(String.self, forKey: .entityName) ?? "Pin_V2"
        self.usdzFileName = try container.decodeIfPresent(String.self, forKey: .usdzFileName)
        self.usdzFileURL = try container.decodeIfPresent(URL.self, forKey: .usdzFileURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)

        // dictionary format of visionOS 2
        try container.encode(["degrees": latitude.degrees], forKey: .latitudeDegrees)
        try container.encode(["degrees": longitude.degrees], forKey: .longitudeDegrees)

        try container.encode(offset, forKey: .offset)
        try container.encode(modelOffset, forKey: .modelOffset)
        try container.encode(text, forKey: .text)
        if !description.isEmpty { try container.encode(description, forKey: .description) }
        if !imageNames.isEmpty { try container.encode(imageNames, forKey: .imageNames) }
        try container.encodeIfPresent(entityName, forKey: .entityName)
        try container.encodeIfPresent(usdzFileName, forKey: .usdzFileName)
        try container.encodeIfPresent(usdzFileURL, forKey: .usdzFileURL)
    }
    
    // MARK: - Position and orientation
    
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

