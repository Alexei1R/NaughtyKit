// Copyright (c) 2025 The Noughy Fox
// https://opensource.org/licenses/MIT

import Foundation
import MetalKit
import SwiftUI

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

public final class Viewport {
    public let id: UUID
    public var name: String
    public var config: ViewportConfig

    weak var delegate: ViewportDelegate?
    weak var eventDelegate: ViewportEventDelegate?

    private var _viewportView: ViewportView?
    private var coordinator: ViewportCoordinator?

    public init(name: String, config: ViewportConfig = ViewportConfig()) {
        self.id = UUID()
        self.name = name
        self.config = config
    }

    @MainActor
    public func getViewportView() -> ViewportView {
        if _viewportView == nil {
            coordinator = ViewportCoordinator(viewport: self)
            _viewportView = ViewportView(coordinator: coordinator!)
        }
        return _viewportView!
    }

    public var hasView: Bool {
        return _viewportView != nil
    }
}

public final class ViewportManager {
    private var viewports: [UUID: Viewport] = [:]
    public private(set) var activeViewport: UUID?

    public init() {}

    @discardableResult
    public func createViewport(
        name: String, 
        delegate: ViewportDelegate? = nil, 
        eventDelegate: ViewportEventDelegate? = nil
    ) -> Viewport {
        let viewport = Viewport(name: name)
        viewport.delegate = delegate
        viewport.eventDelegate = eventDelegate
        viewports[viewport.id] = viewport

        if activeViewport == nil {
            activeViewport = viewport.id
        }

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
              let viewport = viewports[activeId] else {
            return nil
        }
        return viewport.getViewportView()
    }

    public func removeViewport(id: UUID) {
        guard viewports[id] != nil else {
            return
        }

        if activeViewport == id {
            activeViewport = viewports.keys.first(where: { $0 != id })
        }

        viewports.removeValue(forKey: id)
    }

    public func getViewport(id: UUID) -> Viewport? {
        return viewports[id]
    }

    public func getAllViewports() -> [Viewport] {
        return Array(viewports.values)
    }

    public func setActiveViewport(id: UUID) {
        guard viewports[id] != nil else {
            return
        }
        activeViewport = id
    }

    public func getActiveViewport() -> Viewport? {
        guard let activeId = activeViewport else {
            return nil
        }
        return viewports[activeId]
    }
}
