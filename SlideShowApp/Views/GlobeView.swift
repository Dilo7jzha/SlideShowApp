//
//  GlobeView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 28/11/2024.
//

import SwiftUI
import RealityKit

struct GlobeView: View {
    var globeState: GlobeState?  // Optional instead of binding

    var body: some View {
        // If globeState is nil, show a placeholder or no globe.
        if let state = globeState {
            RealityKitGlobeView(globeState: state)  // Pass non-optional state to the view
                .frame(height: 400)
        } else {
            Text("No globe state available")
                .foregroundColor(.gray)
                .font(.title)
        }
    }
}



struct RealityKitGlobeView: View {
    @StateObject private var globeModel = GlobeModel()
    var globeState: GlobeState  // Non-optional GlobeState

    var body: some View {
        RealityView { content in
            globeModel.addGlobe(to: content)
            globeModel.globeState = globeState // No optional handling here
        } update: { _ in }
    }
}


class GlobeModel: ObservableObject {
    private let globeEntity = ModelEntity()
    @Published var globeState: GlobeState? {
        didSet {
            updateGlobePosition() // This will update the globe position when globeState changes
        }
    }

    init() {
        let sphere = MeshResource.generateSphere(radius: 0.1)
        do {
            let texture = try TextureResource.load(named: "globe_texture")
            var material = SimpleMaterial()
            material.baseColor = .texture(texture) //A warning is shown here but it's working fine

            globeEntity.model = ModelComponent(mesh: sphere, materials: [material])
        } catch {
            print("Failed to load texture: \(error.localizedDescription)")
        }
    }

    func addGlobe(to content: RealityViewContent) {
        content.add(globeEntity) // Adds the globe to RealityView
    }

    private func updateGlobePosition() {
        guard let position = globeState?.position else {
            globeEntity.transform.translation = .zero // Default position if no globe state is available
            return
        }
        globeEntity.transform.translation = position // Apply the position from globeState
    }
}







