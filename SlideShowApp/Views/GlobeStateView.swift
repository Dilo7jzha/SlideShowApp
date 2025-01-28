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
            

            Section("Annotations") {
                Button(action: {
                    addNewAnnotation()
                }) {
                    Label("Add Annotation", systemImage: "plus")
                }
                
                ForEach(globeState?.annotations ?? []) { annotation in
                    VStack {
                        TextField("Annotation Text", text: annotationTextBinding(for: annotation.id))
                            .textFieldStyle(.roundedBorder)

                        Grid(alignment: .leading) {
                            GridRow {
                                Text("Latitude")
                                TextField("Latitude", value: annotationLatitudeBinding(for: annotation.id), formatter: formatter(min: -90, max: +90))
                                    .modifier(NumberField())
                                Slider(value: annotationLatitudeBinding(for: annotation.id), in: -90...90)
                                    .labelsHidden()
                            }
                            GridRow {
                                Text("Longitude")
                                TextField("Longitude", value: annotationLongitudeBinding(for: annotation.id), formatter: formatter(min: -180, max: +180))
                                    .modifier(NumberField())
                                Slider(value: annotationLongitudeBinding(for: annotation.id), in: -180...180)
                                    .labelsHidden()
                            }
                            GridRow {
                                Text("Offset")
                                TextField("Offset", value: annotationOffsetBinding(for: annotation.id), formatter: formatter(min: 0, max: 1))
                                    .modifier(NumberField())
                                Slider(value: annotationOffsetBinding(for: annotation.id), in: 0...1)
                                    .labelsHidden()
                            }
                        }

                        Button(action: { removeAnnotation(id: annotation.id) }) {
                            Label("Remove Annotation", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
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
    private func addNewAnnotation() {
        let newAnnotation = Annotation(
            latitude: Angle(degrees: 0), // Default latitude
            longitude: Angle(degrees: 0), // Default longitude
            offset: 0.0, // Default offset
            text: "New Annotation"
        )
        globeState?.annotations.append(newAnnotation)
    }

    // Function to remove an annotation
    private func removeAnnotation(id: UUID) {
        globeState?.annotations.removeAll { $0.id == id }
    }

    // Bindings for annotation editing
    private func annotationTextBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { globeState?.annotations.first { $0.id == id }?.text ?? "" },
            set: { newValue in
                if let index = globeState?.annotations.firstIndex(where: { $0.id == id }) {
                    globeState?.annotations[index].text = newValue
                }
            }
        )
    }

    private func annotationLatitudeBinding(for id: UUID) -> Binding<Double> {
        Binding<Double>(
            get: { globeState?.annotations.first { $0.id == id }?.latitude.degrees ?? 0 },
            set: { newValue in
                if let index = globeState?.annotations.firstIndex(where: { $0.id == id }) {
                    globeState?.annotations[index].latitude = Angle(degrees: newValue)
                }
            }
        )
    }

    private func annotationLongitudeBinding(for id: UUID) -> Binding<Double> {
        Binding<Double>(
            get: { globeState?.annotations.first { $0.id == id }?.longitude.degrees ?? 0 },
            set: { newValue in
                if let index = globeState?.annotations.firstIndex(where: { $0.id == id }) {
                    globeState?.annotations[index].longitude = Angle(degrees: newValue)
                }
            }
        )
    }

    private func annotationOffsetBinding(for id: UUID) -> Binding<Float> {
        Binding<Float>(
            get: { globeState?.annotations.first { $0.id == id }?.offset ?? 0 },
            set: { newValue in
                if let index = globeState?.annotations.firstIndex(where: { $0.id == id }) {
                    globeState?.annotations[index].offset = newValue
                }
            }
        )
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
