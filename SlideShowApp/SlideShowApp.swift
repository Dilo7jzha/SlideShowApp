//
//  SlideShowApp.swift
//  SlideshowApp
//
//  Created by D'Angelo Zhang on 1/11/2024.
//

import SwiftUI

@main
struct SlideShowApp: App {
    @State private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowResizability(.contentSize) // window resizability is derived from window content
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            GlobeView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
 
