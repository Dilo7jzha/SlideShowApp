//
//  ResourceLoader.swift
//  Globes
//
//  Created by Bernhard Jenny on 7/5/2024.
//

import RealityKit
import SwiftUI

struct ResourceLoader {
    private init() {}
    
    @MainActor
    /// Load a globe material, including a texture, and create a high-quality mipmap.
    ///
    /// Creating mipmaps requires a lot of memory. To avoid out-of-memory errors that terminate the app, the `SerialGlobeLoader` should be used instead when loading large textures.
    /// - Parameters:
    ///   - globe: The globe
    ///   - loadPreviewTexture: If true, a small texture image is loaded from the asset catalogue.
    ///   - roughness: Roughness index of the material between 0 and 1.  A small roughness results in shiny reflection, large roughness results in a matte appearance.
    ///   - clearcoat: Simulate clear transparent coating between 0 (none) and 1.
    /// - Returns: A physically based material.
    static func loadMaterial(globe: Globe, loadPreviewTexture: Bool, roughness: Float?, clearcoat: Float?) async throws -> PhysicallyBasedMaterial {
        let textureResource = try await loadTexture(globe: globe, loadPreviewTexture: loadPreviewTexture)
        var material = PhysicallyBasedMaterial()
        material.baseColor.texture = MaterialParameters.Texture(textureResource, sampler: highQualityTextureSampler)
        
        if let roughness {
            assert(roughness >= 0 && roughness <= 1, "Roughness out of bounds.")
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: roughness)
        }
        
        if let clearcoat {
            assert(clearcoat >= 0 && clearcoat <= 1, "Clearcoat out of bounds.")
            material.clearcoat = .init(floatLiteral: clearcoat)
        }
        
        return material
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
    
    @MainActor
    /// Load a texture resource from the app bundle (for full resolution) or the assets store (for preview globes).
    private static func loadTexture(globe: Globe, loadPreviewTexture: Bool) async throws -> TextureResource {
        let textureOptions = TextureResource.CreateOptions(semantic: .color, mipmapsMode: .allocateAndGenerateAll)
        
        // load texture from assets
        return try await TextureResource(named: globe.texture, options: textureOptions)
    }
}
