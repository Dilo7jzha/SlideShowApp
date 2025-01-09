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
#endif
    
#if os(visionOS) || os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#else
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(visionOS)
                .onAppear {
                    Task { @MainActor in
                        await appModel.openImmersiveSpace(with: openImmersiveSpace)
                    }
                }
#endif
                .environment(appModel)
        }
        .windowResizability(.contentSize) // window resizability is derived from window content
        
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
#elseif os(macOS)
        Window("Globe Preview", id: AppModel.macOSGlobeViewID) {
            GlobeView()
                .environment(appModel)
                .frame(minWidth: 300, minHeight: 300)
        }
        .windowResizability(.contentSize) // window resizability is derived from window content
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
