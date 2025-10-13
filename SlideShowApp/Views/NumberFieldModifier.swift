//
//  NumberFieldModifier.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 10/10/2025.
//

import SwiftUI

struct NumberFieldModifier: ViewModifier {
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

extension View {
    func numberField() -> some View {
        self.modifier(NumberFieldModifier())
    }
}
