//
//  Formatter.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 11/10/2025.
//

import SwiftUI

enum Formatter {
    static let position: NumberFormatter = Self.formatter(min: -5, max: 5)
    static let latitude: NumberFormatter = Self.formatter(min: -90, max: 90)
    static let longitude: NumberFormatter = Self.formatter(min: -180, max: 180)
    static let scale: NumberFormatter = Self.formatter(min: 0, max: 10)
    static let globeSurfaceOffset: NumberFormatter = Self.formatter(min: 0, max: 1)
    
    static func formatter(
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
}
