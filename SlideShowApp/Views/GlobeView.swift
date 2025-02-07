//
//  GlobeView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 28/11/2024.
//

import SwiftUI
import RealityKit

struct GlobeView: View {
    @Environment(AppModel.self) private var appModel
    @State private var globeEntity: GlobeEntity? = nil
    @State private var annotationEntities: [UUID: Entity] = [:] // Track annotation entities

    var body: some View {
        RealityView { content in
            let anchor = AnchorEntity()
            content.add(anchor)
#if os(visionOS)
            anchor.position = [0, 1, -0.8]
#endif
            do {
                globeEntity = try await GlobeEntity(globe: appModel.globe)
            } catch {
                appModel.errorToShowInAlert = error
            }
            globeEntity?.setParent(anchor)
            try? updateGlobeTransformation()
            updateAnnotations()
        }
        .onChange(of: appModel.selectedStoryPointID) { _ in
            try? updateGlobeTransformation()
            updateAnnotations()
        }
    }

    /// Updates the globe's position, scale, and orientation based on the accumulated state.
    private func updateGlobeTransformation() throws {
        guard let globeEntity else { return }
        let accumulatedGlobeState = try appModel.story.accumulatedGlobeState(for: appModel.selectedStoryPointID)
        let orientation = accumulatedGlobeState.orientation(globeCenter: globeEntity.position)

        globeEntity.animateTransform(
            scale: accumulatedGlobeState.scale,
            orientation: orientation,
            position: accumulatedGlobeState.position,
            duration: 2
        )
    }

    /// Updates annotations using RealityKit's `Attachment` API.
    private func updateAnnotations() {
        guard let storyPoint = appModel.story.storyPoints.first(where: { $0.id == appModel.selectedStoryPointID }) else { return }

        // Remove previous annotations
        annotationEntities.values.forEach { $0.removeFromParent() }
        annotationEntities.removeAll()

        for annotationID in storyPoint.annotationIDs {
            if let annotation = appModel.story.annotations.first(where: { $0.id == annotationID }) {
                let position = annotation.positionOnGlobe(radius: appModel.globe.radius)

                Task {
                    let pinEntity = await loadPinEntity()
                    pinEntity.position = position

                    if let globeEntity = globeEntity {
                        let attachmentEntity = ModelEntity()
                        attachmentEntity.position = position
                        attachmentEntity.setParent(globeEntity)

                        attachmentEntity.addChild(pinEntity) // Attach the pin to this wrapper

                        let textEntity = createTextEntity(for: annotation.text)
                        textEntity.position = [0, 0.01, 0] // Position text slightly above pin
                        attachmentEntity.addChild(textEntity)

                        annotationEntities[annotationID] = attachmentEntity
                    }
                }
            }
        }
    }


    /// Loads the 3D pin model (`Pin.usdz`)
    private func loadPinEntity() async -> Entity {
        do {
            let pinEntity = try await Entity.load(named: "Pin.usdz")
            pinEntity.scale = [0.02, 0.02, 0.02] // Adjust size
            return pinEntity
        } catch {
            print("Failed to load Pin.usdz: \(error)")
            return Entity()
        }
    }

    /// Creates an entity with a text mesh, a `BillboardComponent`, and an `AnnotationComponent`.
    private func createTextEntity(for text: String) -> Entity {
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: 0.02),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let textModel = ModelEntity(mesh: textMesh, materials: [material])
        textModel.components.set(BillboardComponent()) // Keeps text facing the camera
        
        // Store the annotation text with the entity, such that we can later determine whether
        // the text changed and the mesh needs to be recreated
        textModel.components.set(AnnotationComponent(annotation: text))
        
        return textModel
    }
}
