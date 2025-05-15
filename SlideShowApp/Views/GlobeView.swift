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
    @State private var attachmentEntities: Entity? = nil
    
    var body: some View {
        RealityView { content, attachments in
            let anchor = AnchorEntity()
            content.add(anchor)
            
#if os(visionOS)
            anchor.position = [0, 1, -0.8]
#endif
            do {
                let globeEntity = try await GlobeEntity(globe: appModel.globe)
                globeEntity.setParent(anchor)
                appModel.globeEntity = globeEntity
                
                attachmentEntities = Entity()
                globeEntity.stateEntity.addChild(attachmentEntities!)
                
                updateGlobeTransformation()
                await updateAnnotationPosition(attachments: attachments)
            } catch {
                appModel.errorToShowInAlert = error
            }
        } update: { content, attachments in
            Task { @MainActor in
                await updateAnnotationPosition(attachments: attachments)
            }
        } attachments: {
            ForEach(appModel.story.annotations) { annotation in
                Attachment(id: annotation.id) {
                    GlobeAttachmentView(annotation: annotation)
                }
            }
        }
        .onChange(of: appModel.story) {
            updateGlobeTransformation()
        }
        .onChange(of: appModel.selectedStoryPointID) {
            updateGlobeTransformation()
        }
        .globeGestures(model: appModel)
    }
    
    private func updateGlobeTransformation() {
        if let accumulatedGlobeState = try? appModel.story.accumulatedGlobeState(for: appModel.selectedStoryPointID)  {
            appModel.globeEntity?.applyState(accumulatedGlobeState)
        }
    }
    
    /// Updates annotation positions dynamically when the selected story point changes.
    private func updateAnnotationPosition(attachments: RealityViewAttachments) async {
        attachmentEntities?.children.removeAll()

        guard let storyPoint = appModel.story.storyPoints.first(where: { $0.id == appModel.selectedStoryPointID }) else { return }
        
        for annotationID in storyPoint.annotationIDs {
            guard let annotation = appModel.story.annotations.first(where: { $0.id == annotationID }),
                  let viewEntity = attachments.entity(for: annotation.id) else { continue }
            
            // parent entity for view entity and geometry entity
            let attachmentEntity = Entity()
            attachmentEntities?.addChild(attachmentEntity)
            
            // view entity - adjust position based on whether it has a description
            let additionalOffset: Float = annotation.description.isEmpty ? 0 : 0.01
            let viewOffset = annotation.offset + additionalOffset
            let viewPosition = annotation.positionOnGlobe(radius: appModel.globe.radius + viewOffset)
            
            viewEntity.position = viewPosition
            viewEntity.components.set(BillboardComponent())
            attachmentEntity.addChild(viewEntity)
            
            // geometry entity
            if let entityName = annotation.entityName {
                if let geometryEntity = try? await Entity(named: entityName) {
                    let geometryPosition = annotation.positionOnGlobe(radius: appModel.globe.radius)
                    geometryEntity.position = geometryPosition
                    geometryEntity.orientation = annotation.orientation(for: geometryPosition)
                    attachmentEntity.addChild(geometryEntity)
                    
                    // Use a more appropriate scale based on globe size
                    let scaleMultiplier: Float = 0.01 / appModel.globe.radius * 0.2
                    geometryEntity.scale = [scaleMultiplier, scaleMultiplier, scaleMultiplier]
                }
            }
            
            // Handle any already displayed 3D models by repositioning them
            if let usdzFileName = annotation.usdzFileName,
               let modelEntity = appModel.globeEntity?.findEntity(named: "annotationModel_\(annotation.id)") {
                
                // Recalculate position for any existing 3D model
                let basePosition = annotation.positionOnGlobe(radius: appModel.globe.radius)
                let normalVector = normalize(basePosition)
                
                // Use the modelOffset property for proper positioning
                let finalPosition = basePosition + normalVector * annotation.modelOffset
                
                // Update the position
                modelEntity.position = finalPosition
                
                // Update orientation to face outward from the globe
                modelEntity.orientation = annotation.orientation(for: basePosition)
            }
        }
    }
}
