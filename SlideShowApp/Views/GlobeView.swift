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
            var material = PhysicallyBasedMaterial()
            material.baseColor.texture = MaterialParameters.Texture(texture, sampler: Self.highQualityTextureSampler)
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
    
    /// Highest possible quality for mipmap texture sampling
    private static var highQualityTextureSampler: MaterialParameters.Texture.Sampler {
        let samplerDescription = MTLSamplerDescriptor()
        samplerDescription.maxAnisotropy = 16 // 16 is maximum number of samples for anisotropic filtering (default is 1)
        samplerDescription.minFilter = MTLSamplerMinMagFilter.linear // linear filtering (instead of nearest) when texture pixels are larger than rendered pixels
        samplerDescription.magFilter = MTLSamplerMinMagFilter.linear // linear filtering (instead of nearest) when texture pixels are smaller than rendered pixels
        samplerDescription.mipFilter = MTLSamplerMipFilter.linear // linear interpolation between mipmap levels
        return MaterialParameters.Texture.Sampler(samplerDescription)
    }
}
