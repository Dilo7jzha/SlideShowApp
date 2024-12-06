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
    @State private var globeEntity: GlobeEntity? = nil
    
    var body: some View {
        RealityView { content in // async on MainActor
            rootEntity.position = [0, 0, 0]
            do {
                globeEntity = try await GlobeEntity(globe: appModel.globe)
            } catch {
                print("Failed to load texture: \(error.localizedDescription)")
            }
            globeEntity?.setParent(rootEntity)
            content.add(rootEntity)
            globeEntity?.isEnabled = false
        } update: { _ in // synchronous on MainActor
        }
        .onChange(of: appModel.selectedStoryPoint) {
            globeEntity?.isEnabled = (appModel.selectedStoryPointID != nil)
            try? updateGlobeTransformation()
        }
    }
    
    private func updateGlobeTransformation() throws {
        let globeState = try appModel.story.accumulatedGlobeState(for: appModel.selectedStoryPointID)
        globeEntity?.animateTransform(
            scale: globeState.scale,
            orientation: globeState.orientation,
            position: globeState.position,
            duration: 2
        )
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
