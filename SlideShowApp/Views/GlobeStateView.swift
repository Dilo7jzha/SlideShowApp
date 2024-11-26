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
                    Group {
                        TextField("X", value: positionXBinding, formatter: formatter())
                        TextField("Y", value: positionYBinding, formatter: formatter())
                        TextField("Z", value: positionZBinding, formatter: formatter())
                    }
                    .modifier(NumberField())
                }
            }
            
            ControlGroup("Focus Point") {
                LabeledContent("Latitude") {
                    TextField("Latitude", value: focusLatitudeBinding, formatter: formatter(min: -90, max: +90))
                        .modifier(NumberField())
                }
                LabeledContent("Longitude") {
                    TextField("Longitude", value: focusLongitudeBinding, formatter: formatter(min: -180, max: +180))
                        .modifier(NumberField())
                }
            }
            
            ControlGroup("Globe Size") {
                LabeledContent("Scale") {
                    TextField("Scale", value: scaleBinding, formatter: formatter(min: 0))
                        .modifier(NumberField())
                }
            }
        }
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
    
    private var positionXBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.position.x ?? 0 },
            set: { globeState?.position.x = $0 })
    }
    
    private var positionYBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.position.y ?? 0 },
            set: { globeState?.position.y = $0 })
    }
    
    private var positionZBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.position.z ?? 0 },
            set: { globeState?.position.z = $0 })
    }
    
    private var focusLatitudeBinding: Binding<Double> {
        Binding<Double>(
            get: { globeState?.focusLatitude.degrees ?? 0 },
            set: { globeState?.focusLatitude = Angle(degrees: $0) })
    }
    
    private var focusLongitudeBinding: Binding<Double> {
        Binding<Double>(
            get: { globeState?.focusLongitude.degrees ?? 0 },
            set: { globeState?.focusLongitude = Angle(degrees: $0) })
    }
    
    private var scaleBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.scale ?? 0 },
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
