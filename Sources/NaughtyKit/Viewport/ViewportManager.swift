// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation
import MetalKit
import SwiftUI

/// Viewport configuration
public struct ViewportConfig {
    public var clearColor: MTLClearColor
    public var isEnabled: Bool

    public init(
        clearColor: MTLClearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0),
        isEnabled: Bool = true
    ) {
        self.clearColor = clearColor
        self.isEnabled = isEnabled
    }
}

/// Viewport information
public final class Viewport {
    public let id: UUID
    public var name: String
    public var config: ViewportConfig

    private var _viewportView: ViewportView?

    public init(name: String, config: ViewportConfig = ViewportConfig()) {
        self.id = UUID()
        self.name = name
        self.config = config
    }

    @MainActor
    public func getViewportView() -> ViewportView {
        if _viewportView == nil {
            Log.info(" Creating new ViewportView for '\(name)' (ID: \(id))")
            _viewportView = ViewportView()
        }
        return _viewportView!
    }

    public var hasView: Bool {
        return _viewportView != nil
    }
}

/// Viewport manager resource
public final class ViewportManager {
    private weak var world: World?
    private var viewports: [UUID: Viewport] = [:]
    public private(set) var activeViewport: UUID?

    public init(world: World) {
        self.world = world
        Log.info(" Initialized")
    }

    @discardableResult
    public func createViewport(name: String) -> Viewport {
        let viewport = Viewport(name: name)
        viewports[viewport.id] = viewport

        if activeViewport == nil {
            activeViewport = viewport.id
            Log.info(" Set '\(name)' as active viewport (ID: \(viewport.id))")
        }

        Log.info(" Created viewport '\(name)' (ID: \(viewport.id))")
        return viewport
    }

    @MainActor
    public func getViewportView(for id: UUID) -> ViewportView? {
        guard let viewport = viewports[id] else {
            return nil
        }

        return viewport.getViewportView()
    }

    @MainActor
    public func getActiveViewportView() -> ViewportView? {
        guard let activeId = activeViewport,
            let viewport = viewports[activeId]
        else {
            Log.info(" Cannot get active viewport view: No active viewport")
            return nil
        }

        let view = viewport.getViewportView()
        return view
    }

    public func removeViewport(id: UUID) {
        guard let viewport = viewports[id] else {
            return
        }

        if activeViewport == id {
            activeViewport = viewports.keys.first(where: { $0 != id })
            Log.info(
                "Active viewport removed, new active: \(activeViewport?.uuidString ?? "None")"
            )
        }

        viewports.removeValue(forKey: id)
        Log.info("Removed viewport '\(viewport.name)' (ID: \(id))")
    }

    public func getViewport(id: UUID) -> Viewport? {
        return viewports[id]
    }

    public func getAllViewports() -> [Viewport] {
        return Array(viewports.values)
    }

    public func setActiveViewport(id: UUID) {
        guard let viewport = viewports[id] else {
            return
        }

        activeViewport = id
        Log.info("Set '\(viewport.name)' as active viewport (ID: \(id))")
    }

    public func getActiveViewport() -> Viewport? {
        guard let activeId = activeViewport else {
            return nil
        }
        return viewports[activeId]
    }
}
