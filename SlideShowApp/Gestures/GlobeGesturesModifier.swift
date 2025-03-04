import ARKit
import os
import RealityKit
import SwiftUI

extension View {
    @MainActor
    func globeGestures(model: AppModel) -> some View {
        self.modifier(
            GlobeGesturesModifier(model: model)
        )
    }
}

@MainActor
private struct GlobeGesturesModifier: ViewModifier {

    struct GlobeGestureState {
        var isDragging = false
        var isScaling: Bool { scaleAtGestureStart != nil }
        var isRotating: Bool { orientationAtGestureStart != nil }
        var positionAtGestureStart: SIMD3<Float>? = nil
        var scaleAtGestureStart: Float? = nil
        var orientationAtGestureStart: Rotation3D? = nil
        var localRotationAtGestureStart: simd_quatf? = nil
        var cameraPositionAtGestureStart: SIMD3<Float>? = nil
        var isRotationPausedAtGestureStart: Bool? = nil
        var previousLocation3D: Point3D? = nil

        mutating func endGesture() {
            isDragging = false
            positionAtGestureStart = nil
            scaleAtGestureStart = nil
            orientationAtGestureStart = nil
            localRotationAtGestureStart = nil
            cameraPositionAtGestureStart = nil
            isRotationPausedAtGestureStart = nil
            previousLocation3D = nil
        }
    }

    let model: AppModel
    @State private var state = GlobeGestureState()
    @GestureState private var yRotationState = YRotationState.inactive

    private enum YRotationState {
        case inactive
        case pressing
        case dragging(translation: CGSize)

        var isActive: Bool {
            switch self {
            case .inactive: return false
            case .pressing, .dragging: return true
            }
        }
    }

    private let minimumLongPressDuration = 0.5
    private let rotationSpeed: Float = 0.0015
    private let animationDuration = 0.2
    private let maxDistanceToCameraWhenTapped: Float = 1.5

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(doubleTapGesture)
            .simultaneousGesture(singleTapGesture)
            .simultaneousGesture(dragGesture)
            .simultaneousGesture(magnifyGesture)
            .simultaneousGesture(rotateGesture)
            .simultaneousGesture(rotateGlobeAxisGesture)
    }

    private var singleTapGesture: some Gesture {
        SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            model.configuration.showAttachment.toggle()

            if model.configuration.showAttachment, let globeEntity = model.globeEntity {
                let scaledRadius = model.globe.radius * globeEntity.meanScale
                if let distance = try? globeEntity.distanceToCamera(radius: scaledRadius),
                   distance > maxDistanceToCameraWhenTapped {
                    globeEntity.moveTowardCamera(distance: maxDistanceToCameraWhenTapped, radius: scaledRadius, duration: 1)
                }
            }
        }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2).targetedToAnyEntity().onEnded {_ in 
            model.configuration.isRotationPaused.toggle()
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard let globeEntity = model.globeEntity else { return }
                    if !state.isScaling, !state.isRotating, !yRotationState.isActive {
                        if state.positionAtGestureStart == nil {
                            state.isDragging = true
                            state.positionAtGestureStart = globeEntity.position(relativeTo: nil)
                            state.localRotationAtGestureStart = globeEntity.orientation
                        }

                        if let positionStart = state.positionAtGestureStart,
                           let localRotationStart = state.localRotationAtGestureStart,
                           let cameraPosition = CameraTracker.shared.position {

                            let location3D = value.convert(value.location3D, from: .local, to: .scene)
                            let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                            let delta = location3D - startLocation3D
                            let position = positionStart + delta

                            var v1 = cameraPosition - positionStart
                            var v2 = cameraPosition - position
                            v1.y = 0
                            v2.y = 0
                            let rotationSinceStart = simd_quatf(from: normalize(v1), to: normalize(v2))
                            let localRotationSinceStart = simd_quatf(value.convert(rotation: rotationSinceStart, from: .scene, to: .local))
                            let rotation = simd_mul(localRotationSinceStart, localRotationStart)

                            globeEntity.animateTransform(orientation: rotation, position: position, duration: animationDuration)
                        }
                    }
                }
            }
            .onEnded { _ in state.endGesture() }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .targetedToAnyEntity()
            .onChanged { value in
                guard let globeEntity = model.globeEntity else { return }
                if !state.isRotating, !yRotationState.isActive {
                    if !state.isScaling {
                        state.scaleAtGestureStart = globeEntity.meanScale
                    }
                    if let initialScale = state.scaleAtGestureStart {
                        let newScale = initialScale * Float(value.magnification)
                        globeEntity.scale = [newScale, newScale, newScale]
                    }
                }
            }
            .onEnded { _ in state.endGesture() }
    }

    private var rotateGesture: some Gesture {
        RotateGesture3D().targetedToAnyEntity().onChanged { value in
            guard let globeEntity = model.globeEntity else { return }
            if !state.isScaling, !yRotationState.isActive {
                if !state.isRotating {
                    state.orientationAtGestureStart = Rotation3D(globeEntity.orientation(relativeTo: nil))
                    pauseRotationAndStoreRotationState()
                }
                if let initialOrientation = state.orientationAtGestureStart {
                    let flippedRotation = Rotation3D(
                        angle: value.rotation.angle,
                        axis: RotationAxis3D(x: -value.rotation.axis.x, y: value.rotation.axis.y, z: -value.rotation.axis.z)
                    )
                    let newOrientation = initialOrientation.rotated(by: flippedRotation)
                    globeEntity.orientation = simd_quatf(newOrientation)
                }
            }
        }
        .onEnded { _ in state.endGesture() }
    }

    private var rotateGlobeAxisGesture: some Gesture {
        LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .targetedToAnyEntity()
            .updating($yRotationState) { _, state, _ in
                state = .pressing
            }
            .onEnded { _ in state.endGesture() }
    }

    private func pauseRotationAndStoreRotationState() {
        if state.isRotationPausedAtGestureStart == nil {
            state.isRotationPausedAtGestureStart = model.configuration.isRotationPaused
            model.configuration.isRotationPaused = true
        }
    }
}

