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

    private let rootEntity = Entity()
    private let globeEntity = ModelEntity()
    
    var body: some View {
        RealityView { content in
            rootEntity.position = [0, 1, -1]
            createGlobeEntity()
            globeEntity.setParent(rootEntity)
            content.add(rootEntity)
        } update: { _ in }
            .onChange(of: appModel.selectedStoryPoint) {
                updateGlobeTransformation()
            }
    }
    
    private func createGlobeEntity() {
        let sphere = MeshResource.generateSphere(radius: 0.2)
        do {
            let texture = try TextureResource.load(named: "globe_texture")
            var material = SimpleMaterial()
            material.baseColor = .texture(texture) //A warning is shown here but it's working fine
            globeEntity.model = ModelComponent(mesh: sphere, materials: [material])
            
        } catch {
            print("Failed to load texture: \(error.localizedDescription)")
        }
    }
    
    private func updateGlobeTransformation() {
        if let position = appModel.selectedStoryPoint?.globeState?.position {
            globeEntity.transform.translation = position
        }
    }
}
