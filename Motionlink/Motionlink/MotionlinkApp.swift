//
//  MotionlinkApp.swift
//  Motionlink
//
//  Created by rusu alexei on 28.03.2025.
//

import SwiftUI

@main
struct MotionlinkApp: App {
    var body: some Scene {
        WindowGroup {
            EditorView()
            #if os(iOS)
                .ignoresSafeArea()
            #endif
        }
    }
}
