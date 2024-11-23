//
//  SlideView.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 21/11/2024.
//

import SwiftUI

struct SlideView: View {
    @Binding var slide: Slide // Use a binding to allow editing the slide text and image

    var body: some View {
        VStack {
            if let image = slide.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("No Image")
                    .font(.headline)
                    .padding()
            }

            TextEditor(text: $slide.text) // Text editor for slide text
                .font(.title)
                .padding()
                .border(Color.gray, width: 1)
        }
    }
}
