//
//  InfoPanelEditSheet.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 10/10/2025.
//

import SwiftUI

struct InfoPanelEditSheet: View {
    @Binding var infoPanel: Annotation
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedUSDZFileName: String? = nil
    @State private var isFileImporterPresented: Bool = false
    @State private var selectedUSDZFileURL: URL? = nil
    
    var body: some View {
        VStack {
            Text("Info Panel")
                .font(.title)
            Grid {
                GridRow {
                    Text("Title")
                        .gridColumnAlignment(.trailing)
                    TextField("Info Panel Title", text: $infoPanel.text)
                        .textFieldStyle(.roundedBorder)
                        .gridColumnAlignment(.leading)
                }
                GridRow {
                    Text("Description")
                    TextField("Description (optional)", text: $infoPanel.description)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(5)
                }
                GridRow {
                    Text("Latitude")
                    HStack {
                        TextField("Latitude", value: $infoPanel.latitude.degrees, formatter: Formatter.latitude)
                            .numberField()
                        Slider(value: Binding(
                            get: { infoPanel.latitude.degrees },
                            set: { infoPanel.latitude = .degrees($0) }
                        ), in: -90...90)
                        .labelsHidden()
                    }
                }
                GridRow {
                    Text("Longitude")
                    HStack {
                        TextField("Longitude", value: $infoPanel.longitude.degrees, formatter: Formatter.longitude)
                            .numberField()
                        Slider(value: $infoPanel.longitude.degrees, in: -180...180)
                            .labelsHidden()
                    }
                }
                
                GridRow {
                    Text("Label Offset")
                    TextField("Offset", value: $infoPanel.offset, formatter: Formatter.globeSurfaceOffset)
                        .numberField()
                }
                
                GridRow {
                    Text("3D Model")
                    HStack {
                        Button(action: {
                            isFileImporterPresented = true
                        }) {
                            Text(selectedUSDZFileName ?? "Select USDZ File")
                        }
                    }
                }
                if selectedUSDZFileName != nil {
                    GridRow {
                        Text("Model Offset")
                        HStack {
                            TextField("Model Offset", value: $infoPanel.modelOffset, formatter: Formatter.globeSurfaceOffset)
                                .numberField()
                            Slider(value: $infoPanel.modelOffset, in: 0.001...0.5)
                                .labelsHidden()
                        }
                    }
                }
            }
            
            Button("Close") { dismiss() }
                .padding()
        }
        .padding()
    }
}

#Preview {
    InfoPanelEditSheet(infoPanel: .constant(Annotation(latitude: .zero, longitude: .zero, text: "Test Panel")))
        .padding()
        .glassBackgroundEffect()
}
