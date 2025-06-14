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
#if os(visionOS)
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
#elseif os(macOS)
    @Environment(\.openWindow) private var openWindow
#endif
    
#if os(visionOS) || os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#else
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            Group{
                if appModel.isPresenting {
                    PresentationView()
                } else {
                    ContentView()
                }
            }
#if os(visionOS)
            .onAppear {
                Task { @MainActor in
                    await appModel.openImmersiveSpace(with: openImmersiveSpace)
                }
            }
#endif
            .environment(appModel)
        }
        //.windowResizability(.contentSize) // window resizability is derived from window content
        
#if os(visionOS)
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
        
        // Separate Image Viewer Window for visionOS
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
        
#elseif os(macOS)
        Window("Globe Preview", id: AppModel.macOSGlobeViewID) {
            GlobeView()
                .environment(appModel)
                .frame(minWidth: 300, minHeight: 300)
        }
        .windowResizability(.contentSize) // window resizability is derived from window content
        
        // Separate Image Viewer Window for macOS
        Window("Image Viewer", id: AppModel.imageViewerWindowID) {
            if let image = appModel.currentImageForViewer {
                ImageViewerView(image: image)
                    .environment(appModel)
                    .frame(minWidth: 400, minHeight: 300)
            } else {
                Text("No image selected")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 400, minHeight: 300)
            }
        }
        .windowResizability(.contentSize)
#endif
    }
}

#if os(visionOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerComponentsAndSystems()
        CameraTracker.start()
        return true
    }
}
#else
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerComponentsAndSystems()
    }
}
#endif

func registerComponentsAndSystems() {
    RotationComponent.registerComponent()
    RotationSystem.registerSystem()
}
