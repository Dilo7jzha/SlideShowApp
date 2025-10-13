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
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
            .onAppear {
                Task { @MainActor in
                    await appModel.openImmersiveSpace(with: openImmersiveSpace)
                }
            }
        }
        .windowResizability(.contentSize) // window resizability is derived from window content
        
        ImmersiveSpace(id: AppModel.immersiveSpaceID) {
            GlobeView()
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        // Separate Image Viewer Window
        WindowGroup("Image Viewer", id: "ImageViewer") {
            if let image = appModel.currentImageForViewer {
                ImageViewerView(image: image)
                    .environment(appModel)
            } else {
                Text("No image selected")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerComponentsAndSystems()
        CameraTracker.start()
        return true
    }
}

func registerComponentsAndSystems() {
    RotationComponent.registerComponent()
    RotationSystem.registerSystem()
}
