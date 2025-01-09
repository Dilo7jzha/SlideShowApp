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
        } update: { _ in // synchronous on MainActor
        }
        .onChange(of: appModel.selectedStoryPoint) {
            try? updateGlobeTransformation()
        }
    }
    
    private func updateGlobeTransformation() throws {
        guard let globeEntity else { return }
        let globeState = try appModel.story.accumulatedGlobeState(for: appModel.selectedStoryPointID)
        let orientation = globeState.orientation(globeCenter: globeEntity.position)
        
        globeEntity.animateTransform(
            scale: globeState.scale,
            orientation: orientation,
            position: globeState.position,
            duration: 2
        )
    }
}
