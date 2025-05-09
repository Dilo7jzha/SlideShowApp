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
            model.scale = [0.02, 0.02, 0.02]

            let position = positionOnGlobe(latitude: annotation.latitude, longitude: annotation.longitude) + [0, 0.05, 0]
            model.position = position

            globeEntity.addChild(model)
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
