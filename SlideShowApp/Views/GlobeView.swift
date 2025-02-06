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
    
    /// An entity with a child entity that contains a text mesh
    @State private var annotationEntity: Entity? = nil
    @State private var pinModel: Entity? = nil
       
    var body: some View {
        RealityView { content in // async on MainActor
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
            
            // Add an empty annotation entity
            annotationEntity = Entity()
            globeEntity?.addChild(annotationEntity!)
            
            updateAnnotationPosition()
            updateAnnotationTextEntity()
            
        }
        .onChange(of: appModel.selectedStoryPointID) { _ in
            try? updateGlobeTransformation()
            updateAnnotationPosition()
            updateAnnotationTextEntity()
            // updateAnnotationTextEntity()
        }
    }
    
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

    /// Updates annotation positions when the selected story point changes.
    private func updateAnnotationPosition() {
        guard let storyPoint = appModel.story.storyPoints.first(where: { $0.id == appModel.selectedStoryPointID }) else { return }

        annotationEntity?.children.removeAll()

        for annotationID in storyPoint.annotationIDs {
            if let annotation = appModel.story.annotations.first(where: { $0.id == annotationID }) {
                let position = annotation.positionOnGlobe(radius: appModel.globe.radius)
                let annotationTextEntity = createTextEntity(for: annotation.text)
                annotationTextEntity.position = position
                annotationEntity?.addChild(annotationTextEntity)
            }
        }
    }

    /// Updates annotation text entities when the selected story point changes.
    private func updateAnnotationTextEntity() {
        guard let storyPoint = appModel.story.storyPoints.first(where: { $0.id == appModel.selectedStoryPointID }) else { return }

        let annotations = appModel.story.annotations.filter { storyPoint.annotationIDs.contains($0.id) }
        annotationEntity?.children.removeAll()

        for annotation in annotations {
            let textEntity = createTextEntity(for: annotation.text)
            textEntity.position = annotation.positionOnGlobe(radius: appModel.globe.radius)
            annotationEntity?.addChild(textEntity)
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
