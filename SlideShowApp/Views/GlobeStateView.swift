//
//  GlobeStateView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI

struct GlobeStateView: View {
    @Binding var globeState: GlobeState?
    
    var body: some View {
        Form {
            ControlGroup("Globe Position") {
                LabeledContent("XYZ") {
                    Toggle(isOn: usePositionBinding) { EmptyView() }
                    Group {
                        TextField("X", value: positionXBinding, formatter: formatter())
                        TextField("Y", value: positionYBinding, formatter: formatter())
                        TextField("Z", value: positionZBinding, formatter: formatter())
                    }
                    .modifier(NumberField())
                    .disabled(globeState?.position == nil)
                }
            }
            
            ControlGroup("Focus Point") {
                Toggle(isOn: useFocusPointBinding) { Text("Rotate to Focus Point") }
                LabeledContent("Latitude") {
                    TextField("Latitude", value: focusLatitudeBinding, formatter: formatter(min: -90, max: +90))
                        .modifier(NumberField())
                        .disabled(!rotateToFocusPoint)
                }

                LabeledContent("Longitude") {
                    TextField("Longitude", value: focusLongitudeBinding, formatter: formatter(min: -180, max: +180))
                        .modifier(NumberField())
                        .disabled(!rotateToFocusPoint)
                }
            }
            
            ControlGroup("Globe Size") {
                LabeledContent("Scale") {
                    Toggle(isOn: useScaleBinding) { EmptyView() }
                    TextField("Scale", value: scaleBinding, formatter: formatter(min: 0))
                        .modifier(NumberField())
                        .disabled(globeState?.scale == nil)
                }
            }
        }
        .frame(minWidth: 500)
    }
    
    private func formatter(
        min: Double = -Double.infinity,
        max: Double = .infinity
    ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimum = min as NSNumber
        formatter.maximum = max as NSNumber
        return formatter
    }
    
    private var usePositionBinding: Binding<Bool> {
        Binding<Bool>(
            get: { globeState?.position != nil },
            set: {
                if $0 == false {
                    globeState?.position = nil
                } else if globeState?.position == nil {
                    globeState?.position = .zero
                }
            })
    }
    
    private var positionXBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.position?.x ?? 0 },
            set: { globeState?.position?.x = $0 })
    }
    
    private var positionYBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.position?.y ?? 0 },
            set: { globeState?.position?.y = $0 })
    }
    
    private var positionZBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.position?.z ?? 0 },
            set: { globeState?.position?.z = $0 })
    }
    
    private var rotateToFocusPoint: Bool {
        globeState?.focusLatitude != nil
    }
    
    private var useFocusPointBinding: Binding<Bool> {
        Binding<Bool>(
            get: { rotateToFocusPoint },
            set: {
                if $0 == false {
                    globeState?.focusLatitude = nil
                    globeState?.focusLongitude = nil
                } else if !rotateToFocusPoint {
                    globeState?.focusLatitude = .zero
                    globeState?.focusLongitude = .zero
                }
            })
    }
    
    private var focusLatitudeBinding: Binding<Double> {
        Binding<Double>(
            get: { globeState?.focusLatitude?.degrees ?? 0 },
            set: { newLatitude in
                if globeState?.focusLatitude?.degrees != newLatitude {
                    Task { @MainActor in
                        globeState?.focusLatitude = Angle(degrees: newLatitude)
                    }
                }
            })
    }
    
    private var focusLongitudeBinding: Binding<Double> {
        Binding<Double>(
            get: { globeState?.focusLongitude?.degrees ?? 0 },
            set: { globeState?.focusLongitude = Angle(degrees: $0) })
    }
    
    private var useScaleBinding: Binding<Bool> {
        Binding<Bool>(
            get: { globeState?.scale != nil },
            set: {
                if $0 == false {
                    globeState?.scale = nil
                } else if globeState?.scale == nil {
                    globeState?.scale = 1
                }
            })
    }
    
    private var scaleBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.scale ?? 1 },
            set: { globeState?.scale = $0 })
    }
}

struct NumberField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: 200)
    }
}

#Preview {
    GlobeStateView(globeState: .constant(GlobeState()))
}
