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
    
    private let rootEntity = Entity()
    
    var body: some View {
        RealityView { content in // async on MainActor
#if os(visionOS)
            rootEntity.position = [0, 1, -0.8]
#endif
            do {
                globeEntity = try await GlobeEntity(globe: appModel.globe)
            } catch {
                appModel.errorToShowInAlert = error
            }
            globeEntity?.setParent(rootEntity)
            content.add(rootEntity)
            try? updateGlobeTransformation()
            
            // Add an empty annotation entity
            annotationEntity = Entity()
            globeEntity?.addChild(annotationEntity!)
            
            updateAnnotationPosition()
            updateAnnotationTextEntity()
            
        } update: { _ in // synchronous on MainActor
        }
        .onChange(of: appModel.selectedStoryPoint) {
            try? updateGlobeTransformation()
            updateAnnotationPosition()
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
    
    private var annotationText: String? {
        let annotations = appModel.story.storyPoint(with: appModel.selectedStoryPointID)?.globeState?.annotations
        return annotations?.first?.text
    }
    
    private func updateAnnotationTextEntity() {
        // the text currently shown by the text mesh in the `annotationEntity`
        let entityAnnotationText = annotationEntity?.children.first?.components[AnnotationComponent.self]?.annotation
        
        // the text of the model to display
        let annotations = appModel.story.storyPoint(with: appModel.selectedStoryPointID)?.globeState?.annotations ?? []
        if let annotationText = annotations.first?.text {
            if entityAnnotationText == nil || annotationText != entityAnnotationText! {
                annotationEntity?.children.removeAll()
                let textEntity = createTextEntity(for: annotationText)
                annotationEntity?.addChild(textEntity)
            }
        } else {
            annotationEntity?.children.removeAll()
        }
    }

    private func updateAnnotationPosition() {
        guard let annotations = appModel.story.storyPoint(with: appModel.selectedStoryPointID)?.globeState?.annotations else { return }
        
        annotationEntity?.children.removeAll()

        for annotation in annotations {
            let position = annotation.positionOnGlobe(radius: appModel.globe.radius) // convert lat and lon to XYZ
            let annotationTextEntity = createTextEntity(for: annotation.text)
            annotationTextEntity.position = position
            annotationEntity?.addChild(annotationTextEntity)
        }
    }

    
    /// Creates an entity with a text mesh, a `BillboardComponent` and an `AnnotationComponent`.
    private func createTextEntity(for text: String) -> Entity {
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: 0.05),
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
