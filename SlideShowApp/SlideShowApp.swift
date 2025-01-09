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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#else
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowResizability(.contentSize) // window resizability is derived from window content
        
#if os(visionOS)
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
#else
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
