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
       
    var body: some View {
        RealityView { content, attachments in
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
        } update: { content, attachments in
            updateAnnotationPosition(attachments: attachments)
        } attachments: {
            ForEach(appModel.story.annotations) { annotation in
                Attachment(id: annotation.id) {
                    Text(annotation.text)
                        .font(.title3)
                        .padding(6)
                        .foregroundColor(.red)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
            }
        }
        .onChange(of: appModel.selectedStoryPointID) { _ in
            try? updateGlobeTransformation()
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

    /// Updates annotation positions dynamically when the selected story point changes.
    private func updateAnnotationPosition(attachments: RealityViewAttachments) {
        guard let storyPoint = appModel.story.storyPoints.first(where: { $0.id == appModel.selectedStoryPointID }) else { return }
        
        for annotationID in storyPoint.annotationIDs {
            if let annotation = appModel.story.annotations.first(where: { $0.id == annotationID }) {
                let position = annotation.positionOnGlobe(radius: appModel.globe.radius)
                if let attachmentEntity = attachments.entity(for: annotation.id) {
                    attachmentEntity.position = position
                    attachmentEntity.look(at: .zero, from: position, relativeTo: nil)
                }
            }
        }
    }
}
