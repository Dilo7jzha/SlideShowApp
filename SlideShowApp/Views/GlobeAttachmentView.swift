//
//  GlobeAttachmentView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 29/1/2025.
//

import SwiftUI
import RealityFoundation

struct GlobeAttachmentView: View {
    let annotation: Annotation
    @Environment(AppModel.self) private var appModel
    @State private var isModelVisible = false

    var body: some View {
        Group {
            if let fileName = annotation.usdzFileName {
                Button(action: {
                    Task {
                        await toggle3DModel(named: annotation.usdzFileName ?? "unknown")
                    }
                }) {
                    Text(annotation.text)
                        .font(.title3)
                        .padding(6)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text(annotation.text)
                    .font(.title3)
                    .padding(6)
            }
        }
        .glassBackgroundEffect()
    }

    private func toggle3DModel(named fileName: String) async {
        guard let globeEntity = appModel.globeEntity,
              let url = annotation.usdzFileURL else {
            print("Missing model info")
            return
        }

        let modelName = "annotationModel_\(annotation.id)"

        // If the model is already in the scene, remove it
        if let existing = globeEntity.findEntity(named: modelName) {
            existing.removeFromParent()
            isModelVisible = false
            return
        }

        // Otherwise, load and display the model
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let model = try await Entity.load(contentsOf: url)
            model.name = modelName
            
            // Adjust scale based on globe size to maintain proportions
            let scaleMultiplier: Float = 0.015 // Reduced from 0.02
            model.scale = [scaleMultiplier, scaleMultiplier, scaleMultiplier]

            // Calculate position on globe surface
            let basePosition = positionOnGlobe(latitude: annotation.latitude, longitude: annotation.longitude, radius: appModel.globe.radius)
            
            // Calculate a much shorter offset from the globe surface
            // This is the key change to bring the model closer to the globe
            let offsetDistance: Float = 0.015 // Previously was effectively 0.05
            
            // Calculate normal vector from globe center to the position
            let normalVector = normalize(basePosition)
            
            // Apply the offset along the normal vector
            let finalPosition = basePosition + normalVector * offsetDistance
            
            model.position = finalPosition
            
            // Orient the model to face outward from the globe
            let orientation = annotation.orientation(for: basePosition)
            model.orientation = orientation
            
            // Instead of adding to globeEntity directly, add to stateEntity
            // This keeps the model properly attached during globe rotation
            globeEntity.stateEntity.addChild(model)
            isModelVisible = true
        } catch {
            print("Failed to load 3D model: \(error)")
        }
    }
}

func positionOnGlobe(latitude: Angle, longitude: Angle, radius: Float = 1.0) -> SIMD3<Float> {
    let latRad = Float(latitude.radians)
    let lonRad = Float(longitude.radians)

    let x = radius * cos(latRad) * sin(lonRad)
    let y = radius * sin(latRad)
    let z = radius * cos(latRad) * cos(lonRad)

    return SIMD3<Float>(x, y, z)
}
