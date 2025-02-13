//
//  AnnotationView.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 13/2/2025.
//

import SwiftUI

struct AnnotationView: View {
    let annotation: Annotation

    var body: some View {
        VStack {
            Text(annotation.text)
                .font(.headline)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
