//
//  InfoPanelView.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 10/10/2025.
//

import SwiftUI

struct InfoPanelView: View {
    @Binding var story: Story
    @Binding var storyNode: StoryNode
    @State private var infoPanelToEdit: Annotation?

    var body: some View {
        VStack {
            Form {
                Section("Select Info Panels") {
                    if story.annotations.isEmpty {
                        ContentUnavailableView("Create an info panel.", systemImage: "info.circle.text.page.fill")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ForEach(story.annotations) { annotation in
                            HStack(spacing: 20) {
                                Toggle(annotation.text, isOn: infoPanelSelectionBinding(for: annotation.id))
                                
                                Button {
                                    infoPanelToEdit = annotation
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(.bordered)
                                
                                Button(role: .destructive) {
                                    withAnimation {
                                        story.annotations.removeAll { $0.id == annotation.id }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                let infoPanel = Annotation(latitude: .zero, longitude: .zero, text: "Untitled")
                story.annotations.append(infoPanel)
                infoPanelToEdit = infoPanel
            }) {
                Label("Create Info Panel", image: "plus.circle")
            }
            .padding()
        }
        .sheet(item: $infoPanelToEdit) { infoPanel in
            if let index = story.annotations.firstIndex(where: { $0.id == infoPanel.id }) {
                InfoPanelEditSheet(infoPanel: $story.annotations[index])
            }
        }
    }
    
    private func infoPanelSelectionBinding(for id: UUID) -> Binding<Bool> {
        Binding<Bool>(
            get: { storyNode.annotationIDs.contains(id) },
            set: { newValue in
                if newValue {
                    storyNode.annotationIDs.append(id)
                } else {
                    storyNode.annotationIDs.removeAll { $0 == id }
                }
            }
        )
    }
}
