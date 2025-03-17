//
//  AnnotationsView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 29/1/2025.
//

import SwiftUI

struct AnnotationsView: View {
    @Binding var story: Story // Access to all annotations in the story
    @Binding var isPresented: Bool
    @State private var newAnnotationText: String = ""
    @State private var newAnnotationLatitude: Double = 0.0
    @State private var newAnnotationLongitude: Double = 0.0
    @State private var newAnnotationOffset: Float = 0.05

    var body: some View {
        VStack {
            // Form for creating a new annotation
            Form {
                Section(header: Text("Add New Annotation")) {
                    TextField("Annotation Text", text: $newAnnotationText)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Text("Latitude:")
                        TextField("Latitude", value: $newAnnotationLatitude, formatter: formatter(min: -180, max: 180))
                            .modifier(NumberField())
                        Slider(value: $newAnnotationLatitude, in: -180...180)
                            .labelsHidden()
                    }

                    HStack {
                        Text("Longitude:")
                        TextField("Longitude", value: $newAnnotationLongitude, formatter: formatter(min: -180, max: 180))
                            .modifier(NumberField())
                        Slider(value: $newAnnotationLongitude, in: -180...180)
                            .labelsHidden()
                    }

                    HStack {
                        Text("Offset:")
                        TextField("Offset", value: $newAnnotationOffset, formatter: formatter(min: 0, max: 1))
                            .modifier(NumberField())
                    }

                    Button(action: addAnnotation) {
                        Label("Add Annotation", systemImage: "plus")
                    }
                    .disabled(newAnnotationText.isEmpty) // Prevent adding empty annotations
                }
            }

            // List of existing annotations
            List {
                Section(header: Text("Existing Annotations")) {
                    ForEach(story.annotations) { annotation in
                        VStack(alignment: .leading) {
                            TextField("Text", text: annotationTextBinding(for: annotation.id))
                                .textFieldStyle(.roundedBorder)

                            HStack {
                                Text("Latitude:")
                                TextField("Latitude", value: annotationLatitudeBinding(for: annotation.id), formatter: formatter(min: -180, max: 180))
                                    .modifier(NumberField())
                            }

                            HStack {
                                Text("Longitude:")
                                TextField("Longitude", value: annotationLongitudeBinding(for: annotation.id), formatter: formatter(min: -180, max: 180))
                                    .modifier(NumberField())
                            }

                            HStack {
                                Text("Offset:")
                                TextField("Offset", value: annotationOffsetBinding(for: annotation.id), formatter: formatter(min: 0, max: 1))
                                    .modifier(NumberField())
                            }

                            Button(action: { deleteAnnotation(id: annotation.id) }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        Spacer()
        Button("Close") {
            isPresented = false
        }
        .padding()
        .navigationTitle("Manage Annotations")
    }

    // Function to add a new annotation
    private func addAnnotation() {
        let newAnnotation = Annotation(
            latitude: Angle(degrees: newAnnotationLatitude),
            longitude: Angle(degrees: newAnnotationLongitude),
            offset: newAnnotationOffset,
            text: newAnnotationText
        )
        story.annotations.append(newAnnotation)
        clearNewAnnotationFields()
    }

    // Function to clear the new annotation form
    private func clearNewAnnotationFields() {
        newAnnotationText = ""
        newAnnotationLatitude = 0.0
        newAnnotationLongitude = 0.0
        newAnnotationOffset = 0.05
    }

    // Function to delete an annotation
    private func deleteAnnotation(id: UUID) {
        story.annotations.removeAll { $0.id == id }
    }

    // Formatter for numeric fields
    private func formatter(min: Double = -Double.infinity, max: Double = .infinity) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = min as NSNumber
        formatter.maximum = max as NSNumber
        formatter.maximumFractionDigits = 3
        return formatter
    }

    // Bindings for annotation editing
    private func annotationTextBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { story.annotations.first { $0.id == id }?.text ?? "" },
            set: { newValue in
                if let index = story.annotations.firstIndex(where: { $0.id == id }) {
                    story.annotations[index].text = newValue
                }
            }
        )
    }

    private func annotationLatitudeBinding(for id: UUID) -> Binding<Double> {
        Binding(
            get: { story.annotations.first { $0.id == id }?.latitude.degrees ?? 0.0 },
            set: { newValue in
                if let index = story.annotations.firstIndex(where: { $0.id == id }) {
                    story.annotations[index].latitude = Angle(degrees: newValue)
                }
            }
        )
    }

    private func annotationLongitudeBinding(for id: UUID) -> Binding<Double> {
        Binding(
            get: { story.annotations.first { $0.id == id }?.longitude.degrees ?? 0.0 },
            set: { newValue in
                if let index = story.annotations.firstIndex(where: { $0.id == id }) {
                    story.annotations[index].longitude = Angle(degrees: newValue)
                }
            }
        )
    }

    private func annotationOffsetBinding(for id: UUID) -> Binding<Float> {
        Binding(
            get: { story.annotations.first { $0.id == id }?.offset ?? 0.05 },
            set: { newValue in
                if let index = story.annotations.firstIndex(where: { $0.id == id }) {
                    story.annotations[index].offset = newValue
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
            .labelsHidden()
    }
}
