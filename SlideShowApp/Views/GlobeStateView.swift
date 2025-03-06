//
//  GlobeStateView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI

struct GlobeStateView: View {
    @Binding var globeState: GlobeState

    var body: some View {
        Form {
            Section("Globe Position") {
                toggleRow("Move Globe", isOn: positionEnabledBinding)
                if globeState.position != nil {
                    coordinateFields()
                }
            }

            Section("Focus Point") {
                toggleRow("Rotate to Focus Point", isOn: focusPointEnabledBinding)
                if globeState.focusLatitude != nil {
                    latLonSliders()
                }
            }

            Section("Globe Size") {
                toggleRow("Scale", isOn: scaleEnabledBinding)
                if globeState.scale != nil {
                    scaleField()
                }
            }
        }
    }

    private func toggleRow(_ label: String, isOn: Binding<Bool>) -> some View {
        Toggle(label, isOn: isOn)
    }

    private func coordinateFields() -> some View {
        HStack {
            coordinateField("X", positionXBinding)
            coordinateField("Y", positionYBinding)
            coordinateField("Z", positionZBinding)
        }
    }

    private func coordinateField(_ label: String, _ binding: Binding<Float>) -> some View {
        HStack {
            Text(label)
            TextField(label, value: binding, formatter: numberFormatter())
                .textFieldStyle(.roundedBorder)
        }
    }

    private func latLonSliders() -> some View {
        VStack {
            sliderRow("Latitude", focusLatitudeBinding, -90...90)
            sliderRow("Longitude", focusLongitudeBinding, -180...180)
        }
    }

    private func sliderRow(_ label: String, _ binding: Binding<Double>, _ range: ClosedRange<Double>) -> some View {
        HStack {
            Text(label)
            Slider(value: binding, in: range)
        }
    }

    private func scaleField() -> some View {
        TextField("Scale", value: scaleBinding, formatter: numberFormatter(min: 0))
            .textFieldStyle(.roundedBorder)
    }

    // MARK: - Dynamic Bindings (avoid self-reference errors)

    private var positionEnabledBinding: Binding<Bool> {
        Binding(
            get: { globeState.position != nil },
            set: { globeState.position = $0 ? SIMD3<Float>(0, 0, 0) : nil }
        )
    }

    private var focusPointEnabledBinding: Binding<Bool> {
        Binding(
            get: { globeState.focusLatitude != nil },
            set: {
                if $0 {
                    globeState.focusLatitude = .zero
                    globeState.focusLongitude = .zero
                } else {
                    globeState.focusLatitude = nil
                    globeState.focusLongitude = nil
                }
            }
        )
    }

    private var scaleEnabledBinding: Binding<Bool> {
        Binding(
            get: { globeState.scale != nil },
            set: { globeState.scale = $0 ? 1.0 : nil }
        )
    }

    // Individual coordinate/focus/scale bindings

    private var positionXBinding: Binding<Float> {
        Binding(
            get: { globeState.position?.x ?? 0 },
            set: { globeState.position?.x = $0 }
        )
    }

    private var positionYBinding: Binding<Float> {
        Binding(
            get: { globeState.position?.y ?? 0 },
            set: { globeState.position?.y = $0 }
        )
    }

    private var positionZBinding: Binding<Float> {
        Binding(
            get: { globeState.position?.z ?? 0 },
            set: { globeState.position?.z = $0 }
        )
    }

    private var focusLatitudeBinding: Binding<Double> {
        Binding(
            get: { globeState.focusLatitude?.degrees ?? 0 },
            set: { globeState.focusLatitude = Angle(degrees: $0) }
        )
    }

    private var focusLongitudeBinding: Binding<Double> {
        Binding(
            get: { globeState.focusLongitude?.degrees ?? 0 },
            set: { globeState.focusLongitude = Angle(degrees: $0) }
        )
    }

    private var scaleBinding: Binding<Float> {
        Binding(
            get: { globeState.scale ?? 1 },
            set: { globeState.scale = $0 }
        )
    }

    // Number formatter helper
    private func numberFormatter(min: Double = -Double.infinity, max: Double = .infinity) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimum = NSNumber(value: min)
        formatter.maximum = NSNumber(value: max)
        return formatter
    }
}
