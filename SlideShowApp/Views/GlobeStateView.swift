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
            Section("Globe Position") {
                LabeledContent(content: {
                    HStack {
                        Text("X")
                        TextField("X", value: positionXBinding, formatter: formatter())
                            .modifier(NumberField())
                        Text("Y")
                        TextField("Y", value: positionYBinding, formatter: formatter())
                            .modifier(NumberField())
                        Text("Z")
                        TextField("Z", value: positionZBinding, formatter: formatter())
                            .modifier(NumberField())
                    }
                    .labelsHidden()
                    .disabled(globeState?.position == nil)
                }, label: {
                    Toggle(isOn: usePositionBinding) { Text("Move Globe") }
                        .fixedSize()
                })
            }
            
            Section("Focus Point") {
                Toggle(isOn: useFocusPointBinding) { Text("Rotate to Focus Point") }
                
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Latitude")
                        TextField("Latitude", value: focusLatitudeBinding, formatter: formatter(min: -90, max: +90))
                            .modifier(NumberField())
                        Slider(value: focusLatitudeBinding, in: -90...90)
                            .labelsHidden()
                    }
                    GridRow {
                        Text("Longitude")
                        TextField("Longitude", value: focusLongitudeBinding, formatter: formatter(min: -180, max: +180))
                            .modifier(NumberField())
                        Slider(value: focusLongitudeBinding, in: -180...180)
                            .labelsHidden()
                    }
                }
                .disabled(!rotateToFocusPoint)
            }
            
            Section("Globe Size") {
                LabeledContent(content: {
                    TextField("Scale", value: scaleBinding, formatter: formatter(min: 0))
                        .labelsHidden()
                        .modifier(NumberField())
                        .disabled(globeState?.scale == nil)
                    
                }, label: {
                    Toggle(isOn: useScaleBinding) { Text("Scale") }
                        .fixedSize()
                })
            }
            
            Section("Add Annotation") {
                Toggle(isOn: useAnnotationBinding) { Text("Enable Annotation") }

                Grid(alignment: .leading) {
                    GridRow {
                        Text("X")
                        TextField("X", value: annotationXBinding, formatter: formatter(min: -1, max: 1))
                            .modifier(NumberField())
                        Slider(value: annotationXBinding, in: -1...1)
                            .labelsHidden()
                    }
                    GridRow {
                        Text("Y")
                        TextField("Y", value: annotationYBinding, formatter: formatter(min: -1, max: 1))
                            .modifier(NumberField())
                        Slider(value: annotationYBinding, in: -1...1)
                            .labelsHidden()
                    }
                    GridRow {
                        Text("Z")
                        TextField("Z", value: annotationZBinding, formatter: formatter(min: -1, max: 1))
                            .modifier(NumberField())
                        Slider(value: annotationZBinding, in: -1...1)
                            .labelsHidden()
                    }
                }
                .disabled(globeState?.annotationPosition == nil)
            }
        }
        .formStyle(.grouped) // grouped required for macOS
        .frame(minWidth: 400)
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
            set: { newLongitude in
                if globeState?.focusLongitude?.degrees != newLongitude {
                    Task { @MainActor in
                        globeState?.focusLongitude = Angle(degrees: newLongitude)
                    }
                }
            })
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
    // binding for annotation configs
    private var useAnnotationBinding: Binding<Bool> {
        Binding<Bool>(
            get: { globeState?.annotationPosition != nil },
            set: { globeState?.annotationPosition = $0 ? SIMD3.zero : nil })
    }

    private var annotationXBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.annotationPosition?.x ?? 0 },
            set: { globeState?.annotationPosition?.x = $0 })
    }

    private var annotationYBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.annotationPosition?.y ?? 0 },
            set: { globeState?.annotationPosition?.y = $0 })
    }

    private var annotationZBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState?.annotationPosition?.z ?? 0 },
            set: { globeState?.annotationPosition?.z = $0 })
    }
}

fileprivate struct NumberField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
#if canImport(UIKit)
            .keyboardType(.decimalPad)
#endif
            .multilineTextAlignment(.trailing)
            .monospacedDigit()
            .frame(maxWidth: 200)
            .frame(minWidth: 75)
            .labelsHidden() // visionOS does not render labels for text fields, but macOS does.
    }
}

#Preview {
    GlobeStateView(globeState: .constant(GlobeState()))
}
