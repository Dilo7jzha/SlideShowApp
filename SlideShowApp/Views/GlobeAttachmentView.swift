//
//  GlobeAttachmentView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 29/1/2025.
//

import SwiftUI
import RealityFoundation

struct GlobeAttachmentView: View {
    let annotation: Annotation
    @Environment(AppModel.self) private var appModel
    @State private var isModelVisible = false
    @State private var showingMoreInfo = false
    @Namespace private var animation
    
    var body: some View {
        VStack {
            if annotation.description.isEmpty {
                // Simple view for annotations without descriptions
                simpleView
            } else {
                // Expandable view for annotations with descriptions
                expandableView
            }
        }
    }
    
    // Simple view for annotations without descriptions
    private var simpleView: some View {
        Group {
            if let fileName = annotation.usdzFileName {
                Button(action: {
                    Task {
                        await toggle3DModel(named: annotation.usdzFileName ?? "unknown")
                    }
                }) {
                    Text(annotation.text)
                        .font(.title3)
                        .padding(6)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text(annotation.text)
                    .font(.title3)
                    .padding(6)
            }
        }
        .glassBackgroundEffect()
    }
    
    // Expandable view for annotations with descriptions
    private var expandableView: some View {
        ZStack(alignment: .center) {
            if !showingMoreInfo {
                // Collapsed state
                Group {
                    if let fileName = annotation.usdzFileName {
                        Button(action: {
                            withAnimation(.spring) {
                                showingMoreInfo.toggle()
                            }
                        }) {
                            Text(annotation.text)
                                .matchedGeometryEffect(id: "title", in: animation)
                                .font(.title3)
                                .padding(6)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text(annotation.text)
                            .matchedGeometryEffect(id: "title", in: animation)
                            .font(.title3)
                            .padding(6)
                            .onTapGesture {
                                withAnimation(.spring) {
                                    showingMoreInfo.toggle()
                                }
                            }
                    }
                }
            } else {
                // Expanded state
                VStack(alignment: .leading, spacing: 10) {
                    Text(annotation.text)
                        .matchedGeometryEffect(id: "title", in: animation)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(annotation.description)
                        .font(.body)
                    
                    if let fileName = annotation.usdzFileName {
                        Button("Show 3D Model") {
                            Task {
                                await toggle3DModel(named: annotation.usdzFileName ?? "unknown")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if !annotation.imageNames.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(annotation.imageNames, id: \.self) { imageName in
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                }
                .frame(width: 300)
                .padding()
                .onTapGesture {
                    withAnimation(.spring) {
                        showingMoreInfo.toggle()
                    }
                }
            }
        }
        .glassBackgroundEffect()
    }

    private func toggle3DModel(named fileName: String) async {
        guard let globeEntity = appModel.globeEntity,
              let url = annotation.usdzFileURL else {
            print("Missing model info")
            return
        }

        let modelName = "annotationModel_\(annotation.id)"

        // If the model is already in the scene, remove it
        if let existing = globeEntity.findEntity(named: modelName) {
            existing.removeFromParent()
            isModelVisible = false
            return
        }

        // Otherwise, load and display the model
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let model = try await Entity.load(contentsOf: url)
            model.name = modelName
            
            // Adjust scale based on globe size to maintain proportions
            let scaleMultiplier: Float = 0.015 // Reduced from 0.02
            model.scale = [scaleMultiplier, scaleMultiplier, scaleMultiplier]

            // Calculate position on globe surface
            let basePosition = positionOnGlobe(latitude: annotation.latitude, longitude: annotation.longitude, radius: appModel.globe.radius)
            
            // Use the model offset from annotation
            let offsetDistance: Float = annotation.modelOffset
            
            // Calculate normal vector from globe center to the position
            let normalVector = normalize(basePosition)
            
            // Apply the offset along the normal vector
            let finalPosition = basePosition + normalVector * offsetDistance
            
            model.position = finalPosition
            
            // Orient the model to face outward from the globe
            let orientation = annotation.orientation(for: basePosition)
            model.orientation = orientation
            
            // Add to stateEntity to keep properly attached during globe rotation
            globeEntity.stateEntity.addChild(model)
            isModelVisible = true
        } catch {
            print("Failed to load 3D model: \(error)")
        }
    }
}

func positionOnGlobe(latitude: Angle, longitude: Angle, radius: Float = 1.0) -> SIMD3<Float> {
    let latRad = Float(latitude.radians)
    let lonRad = Float(longitude.radians)

    let x = radius * cos(latRad) * sin(lonRad)
    let y = radius * sin(latRad)
    let z = radius * cos(latRad) * cos(lonRad)

    return SIMD3<Float>(x, y, z)
}
