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
                LabeledContent(content: {
                    HStack(alignment: .top) {
                        VStack {
                            Text("X") // Label
                            TextField("X", value: positionXBinding, formatter: Formatter.position)
                                .numberField()
                            Slider(value: positionXBinding, in: -5...5)
                        }
                        
                        VStack {
                            Text("Y") // Label
                            TextField("Y", value: positionYBinding, formatter: Formatter.position)
                                .numberField()
                            Slider(value: positionYBinding, in: -5...5)
                        }
                        
                        VStack {
                            Text("Z") // Label
                            TextField("Z", value: positionZBinding, formatter: Formatter.position)
                                .numberField()
                            Slider(value: positionZBinding, in: -5...5)
                        }
                    }
                    .disabled(globeState.position == nil) // Disable if position is nil
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
                        TextField("Latitude", value: focusLatitudeBinding, formatter: Formatter.latitude)
                            .numberField()
                        Slider(value: focusLatitudeBinding, in: -90...90)
                            .labelsHidden()
                    }
                    GridRow {
                        Text("Longitude")
                        TextField("Longitude", value: focusLongitudeBinding, formatter: Formatter.longitude)
                            .numberField()
                        Slider(value: focusLongitudeBinding, in: -180...180)
                            .labelsHidden()
                    }
                }
                .disabled(!rotateToFocusPoint)
            }
            
            Section("Globe Size") {
                LabeledContent(content: {
                    TextField("Scale", value: scaleBinding, formatter: Formatter.scale)
                        .labelsHidden()
                        .numberField()
                        .disabled(globeState.scale == nil)
                    
                }, label: {
                    Toggle(isOn: useScaleBinding) { Text("Scale") }
                        .fixedSize()
                })
            }
        }
    }
        
    private var usePositionBinding: Binding<Bool> {
        Binding<Bool>(
            get: { globeState.position != nil },
            set: {
                if !$0 {
                    globeState.position = nil
                } else if globeState.position == nil {
                    globeState.position = .zero
                }
            })
    }
    
    private var positionXBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState.position?.x ?? 0 },
            set: { globeState.position?.x = $0 })
    }
    
    private var positionYBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState.position?.y ?? 0 },
            set: { globeState.position?.y = $0 })
    }
    
    private var positionZBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState.position?.z ?? 0 },
            set: { globeState.position?.z = $0 })
    }
    
    private var rotateToFocusPoint: Bool {
        globeState.focusLatitude != nil
    }
    
    private var useFocusPointBinding: Binding<Bool> {
        Binding<Bool>(
            get: { rotateToFocusPoint },
            set: {
                if !$0 {
                    globeState.focusLatitude = nil
                    globeState.focusLongitude = nil
                } else if !rotateToFocusPoint {
                    globeState.focusLatitude = .zero
                    globeState.focusLongitude = .zero
                }
            })
    }
    
    private var focusLatitudeBinding: Binding<Double> {
        Binding<Double>(
            get: { globeState.focusLatitude?.degrees ?? 0 },
            set: { newLatitude in
                if globeState.focusLatitude?.degrees != newLatitude {
                    Task { @MainActor in
                        globeState.focusLatitude = Angle(degrees: newLatitude)
                    }
                }
            })
    }
    
    private var focusLongitudeBinding: Binding<Double> {
        Binding<Double>(
            get: { globeState.focusLongitude?.degrees ?? 0 },
            set: { newLongitude in
                if globeState.focusLongitude?.degrees != newLongitude {
                    Task { @MainActor in
                        globeState.focusLongitude = Angle(degrees: newLongitude)
                    }
                }
            })
    }
    
    private var useScaleBinding: Binding<Bool> {
        Binding<Bool>(
            get: { globeState.scale != nil },
            set: {
                if !$0 {
                    globeState.scale = nil
                } else if globeState.scale == nil {
                    globeState.scale = 1
                }
            })
    }
    
    private var scaleBinding: Binding<Float> {
        Binding<Float>(
            get: { globeState.scale ?? 1 },
            set: { globeState.scale = $0 })
    }
}
