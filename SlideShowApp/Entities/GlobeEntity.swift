//
//  GlobeEntity.swift
//  Globes
//
//  Created by Bernhard Jenny on 13/3/2024.
//

import os
import RealityKit
import SwiftUI

/// Globe entity with a `stateEntity` child to handle state-based transformations.
/// The parent (`GlobeEntity`) handles freeform gestures (pan, zoom, rotate).
class GlobeEntity: Entity {
    
    /// The child entity that holds the actual globe model.
    var stateEntity = Entity()  // New child that tracks GlobeState-driven transforms.
    
    /// Small roughness results in shiny reflection, large roughness results in matte appearance
    let roughness: Float = 0.4
    
    /// Simulate clear transparent coating between 0 (none) and 1
    let clearcoat: Float = 0.05
    
    /// Duration of animations of scale, orientation, and position in seconds.
    static let transformAnimationDuration: Double = 2
        
    /// Controller for stopping animated transformations.
    var animationPlaybackController: AnimationPlaybackController? = nil

    /// Required init
    @MainActor required init() {
        super.init()
        self.name = "GlobeEntity"
        self.addChild(stateEntity) // Make sure stateEntity is added right away.
    }
    
    /// Globe entity initializer
    /// - Parameters:
    ///   - globe: Globe settings.
    init(globe: Globe) async throws {
        super.init()
        self.name = globe.name

        let material = try await ResourceLoader.loadMaterial(
            globe: globe,
            loadPreviewTexture: false,
            roughness: roughness,
            clearcoat: clearcoat
        )
        try Task.checkCancellation()

        let mesh: MeshResource = .generateSphere(radius: globe.radius)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        modelEntity.name = "Sphere"
        modelEntity.components.set(GroundingShadowComponent(castsShadow: true))

        stateEntity.addChild(modelEntity)  // Attach globe model to stateEntity.

        // Parent handles gestures - requires input and collision.
        components.set(InputTargetComponent())
        components.set(CollisionComponent(shapes: [.generateSphere(radius: globe.radius)]))

        self.addChild(stateEntity) // Ensure stateEntity lives within globeEntity.
    }

    /// Apply state-based transformations to stateEntity (focusLatitude, scale, position)
    func applyState(_ state: GlobeState) {
            guard let position = state.position, let scale = state.scale else { return }
            
            let orientation: simd_quatf
            if let focusLatitude = state.focusLatitude, let focusLongitude = state.focusLongitude {
               orientation = computeOrientationForLatLon(latitude: focusLatitude, longitude: focusLongitude) ?? stateEntity.orientation
            } else {
                orientation = stateEntity.orientation
            }
            
            let duration = GlobeEntity.transformAnimationDuration
            let transform = Transform(
                scale: [scale, scale, scale],
                rotation: orientation,
                translation: position
            )
            
            animationPlaybackController?.stop()
            animationPlaybackController = stateEntity.move(to: transform, relativeTo: nil, duration: duration)
            
            if animationPlaybackController?.isPlaying == false {
                self.stateEntity.transform = transform
            }
        }

    /// Converts latitude and longitude into a target orientation quaternion
    private func computeOrientationForLatLon(latitude: Angle, longitude: Angle) -> simd_quatf? {
        let xyz = latLonToXYZ(latitude: latitude, longitude: longitude, radius: 0.2)
        let up = SIMD3<Float>(0, 1, 0)
        if let xyz {
            return simd_quatf(from: up, to: normalize(xyz))
        }
        return nil
    }

    /// Converts latitude/longitude to XYZ coordinates (used for positioning and orientation)
    private func latLonToXYZ(latitude: Angle, longitude: Angle, radius: Float) -> SIMD3<Float>? {
        let lat = Float(latitude.radians)
        let lon = Float(longitude.radians - .pi / 2)

        let x = radius * cos(lat) * cos(lon)
        let y = radius * cos(lat) * sin(lon)
        let z = radius * sin(lat)

        return SIMD3<Float>(y, z, x)
    }

    /// Direct manipulation for gestures (applied to the parent `GlobeEntity`)
    @MainActor
    func applyTransform(position: SIMD3<Float>?, scale: Float?, orientation: simd_quatf?) {
        if let position = position {
            self.position = position
        }
        if let scale = scale {
            self.scale = [scale, scale, scale]
        }
        if let orientation = orientation {
            self.orientation = orientation
        }
    }

    /// Apply animated transformation directly to parent (used for gestures)
    func animateTransform(
        scale: Float? = nil,
        orientation: simd_quatf? = nil,
        position: SIMD3<Float>? = nil,
        duration: Double? = nil
    ) {
        let duration = duration ?? GlobeEntity.transformAnimationDuration

        let finalScale = scale.map { SIMD3<Float>(repeating: $0) } ?? self.scale
        let finalOrientation = orientation ?? self.orientation
        let finalPosition = position ?? self.position

        let transform = Transform(
            scale: finalScale,
            rotation: finalOrientation,
            translation: finalPosition
        )

        animationPlaybackController?.stop()
        animationPlaybackController = move(to: transform, relativeTo: nil, duration: duration)

        if animationPlaybackController?.isPlaying == false {
            self.transform = transform
        }
    }

    /// Calculate mean scale across axes (used for size-related decisions)
    @MainActor
    var meanScale: Float { scale(relativeTo: nil).sum() / 3 }
}

extension GlobeEntity {
    /// Calculates distance from the camera to the globe surface.
    func distanceToCamera(radius: Float) throws -> Float {
        guard let cameraPosition = CameraTracker.shared.position else {
            throw NSError(domain: "Camera position unavailable", code: 0)
        }
        let globeCenter = position(relativeTo: nil)
        let distance = length(globeCenter - cameraPosition) - radius
        return distance
    }
    
    func moveTowardCamera(distance: Float, radius: Float, duration: Double) {
            guard let cameraPosition = CameraTracker.shared.position else { return }
            let globeCenter = position(relativeTo: nil)
            let vectorToCamera = normalize(cameraPosition - globeCenter)
            let newPosition = cameraPosition - vectorToCamera * (distance + radius)

            animateTransform(position: newPosition, duration: duration)
        }
}
