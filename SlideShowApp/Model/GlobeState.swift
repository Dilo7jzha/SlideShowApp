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

    init() {
        self.position = [0, 0, 0]
        self.focusLatitude = .zero
        self.focusLongitude = .zero
        self.scale = 1
    }

    // MARK: - Codable
    
    /// Custom encoding and decoding for compatibility with vision 2: visionOS 26 changed the JSON encoding format of the `Angle` struct.
    enum CodingKeys: String, CodingKey {
        case position
        case focusLatitude
        case focusLongitude
        case scale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let positionArray = try container.decodeIfPresent([Float].self, forKey: .position) {
            if positionArray.count == 3 {
                self.position = SIMD3<Float>(positionArray[0], positionArray[1], positionArray[2])
            } else {
                self.position = nil
            }
        } else {
            self.position = nil
        }
        
        // dictionary format of visionOS 2
        let latDict = try container.decodeIfPresent([String: Double].self, forKey: .focusLatitude)
        let lonDict = try container.decodeIfPresent([String: Double].self, forKey: .focusLongitude)
        if let latDegrees = latDict?["degrees"], let lonDegrees = lonDict?["degrees"] {
            focusLatitude = .degrees(latDegrees)
            focusLongitude = .degrees(lonDegrees)
        } else {
            focusLatitude = try container.decodeIfPresent(Angle.self, forKey: .focusLatitude)
            focusLongitude = try container.decodeIfPresent(Angle.self, forKey: .focusLongitude)
        }
        
        self.scale = try container.decodeIfPresent(Float.self, forKey: .scale)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let position {
            try container.encode([position.x, position.y, position.z], forKey: .position)
        }
        
        // dictionary format of visionOS 2
        if let focusLatitude {
            try container.encode(["degrees": focusLatitude.degrees], forKey: .focusLatitude)
        }
        if let focusLongitude {
            try container.encode(["degrees": focusLongitude.degrees], forKey: .focusLongitude)
        }
        
        if let scale {
            try container.encode(scale, forKey: .scale)
        }
    }

    // Function to update globe state dynamically
    mutating func updateState(position: SIMD3<Float>?, scale: Float?, orientation: simd_quatf?) {
        if let newPosition = position {
            self.position = newPosition
        }
        if let newScale = scale {
            self.scale = newScale
        }
    }

    func orientation(globeCenter: SIMD3<Float>) -> simd_quatf? {
#warning("Radius")
        let radius = 0.2
        
#if os(visionOS)
        guard let cameraPosition = CameraTracker.shared.position else { return nil }
        let globeToCamera = cameraPosition - globeCenter
#else
        let globeToCamera: SIMD3<Float> = [0, 0, 1]
#endif
        guard let xyz = latLonToXYZ(radius: radius) else { return nil }
        let orientation = simd_quatf(from: normalize(xyz), to:  normalize(globeToCamera))
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
