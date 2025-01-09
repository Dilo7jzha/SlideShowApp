//
//  ToggleImmersiveSpaceButton.swift
//  Test
//
//  Created by Bernhard Jenny on 6/12/2024.
//

import SwiftUI

#if os(visionOS)
struct ToggleImmersiveSpaceButton: View {

    @Environment(AppModel.self) private var appModel

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                case .open:
                    await appModel.dismissImmersiveSpace(with: dismissImmersiveSpace)
                case .closed :
                    await appModel.openImmersiveSpace(with: openImmersiveSpace)
                case .inTransition:
                    break
                }
            }
        } label: {
            Label(appModel.immersiveSpaceState == .open ? "Hide Globe" : "Show Globe", systemImage: "globe")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
#endif
