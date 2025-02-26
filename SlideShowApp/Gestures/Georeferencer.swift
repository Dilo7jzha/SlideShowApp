//
//  Georeferencer.swift
//  SlideShowApp
//
//  Created by D'Angelo Zhang on 27/2/2025.
//

import Foundation
import SwiftUI

class Georeferencer {
    func geocode(lat: Angle, lon: Angle) -> Int? {
        // Simulated lookup logic
        if abs(lat.degrees) < 90, abs(lon.degrees) < 180 {
            return Int.random(in: 1...100)
        }
        return nil
    }
}
