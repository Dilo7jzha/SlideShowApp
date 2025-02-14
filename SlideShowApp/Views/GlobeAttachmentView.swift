//
//  GlobeAttachmentView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 29/1/2025.
//

import SwiftUI

struct GlobeAttachmentView: View {
    let annotation: Annotation
    var body: some View {
        Text(annotation.text)
            .font(.title3)
            .padding(6)
            .glassBackgroundEffect()
    }
}

#Preview {
    GlobeAttachmentView(annotation: Annotation(latitude: .zero, longitude: .zero, offset: 0.02, text: "Hello, World!"))
}
