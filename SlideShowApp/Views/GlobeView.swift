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
            
            // Add annotation attachment
            createTextAnnotationEntity()
            if let annotationEntity {
                globeEntity?.addChild(annotationEntity)
            }
            updateAnnotationPosition()
            
        } update: { _ in // synchronous on MainActor
        }
        .onChange(of: appModel.selectedStoryPoint) {
            try? updateGlobeTransformation()
            updateAnnotationPosition()
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
    
    private func updateAnnotationPosition() {
        guard let storyPointGlobeState = appModel.story.storyPoint(with: appModel.selectedStoryPointID)?.globeState else { return }
        annotationEntity?.isEnabled = (storyPointGlobeState.annotationPosition != nil)
        guard let annotationEntity, let annotationPosition = storyPointGlobeState.annotationPosition else { return }
        var transform = annotationEntity.transform
        transform.translation = annotationPosition
        annotationEntity.move(to: transform, relativeTo: annotationEntity.parent, duration: 1)
    }
    
    /// Create an annotation entity
    private func createTextAnnotationEntity() {
            guard let globeState = appModel.story.storyPoint(with: appModel.selectedStoryPointID)?.globeState,
                  let annotationText = globeState.annotationText, !annotationText.isEmpty else {
                annotationEntity = nil
                return
            }
            
            // Create the text mesh for annotation
            let textEntity = Entity()
            let textMesh = MeshResource.generateText(
                annotationText,
                extrusionDepth: 0.002,
                font: .systemFont(ofSize: 0.05),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let textModel = ModelEntity(mesh: textMesh, materials: [material])
            textModel.components.set(BillboardComponent()) // Keeps text facing the camera
            
            textEntity.addChild(textModel)
            annotationEntity = textEntity
        }
}
