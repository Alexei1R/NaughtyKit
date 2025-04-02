// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation
import MetalKit
import SwiftUI

/// Main engine class that ties together all systems
public final class NaughtyEngine {
    // Engine state
    private var isRunning: Bool = false
    private let viewportManager: ViewportManager
    private let world: World

    public init() {
        self.viewportManager = ViewportManager()
        self.world = World()

        Log.info("NaughtyEngine initialized")
    }

    public func start() {
        guard !isRunning else {
            Log.warning("Engine is already running")
            return
        }

        isRunning = true
        Log.info("Engine started")
    }

    public func stop() {
        guard isRunning else {
            Log.warning("Engine is not running")
            return
        }

        isRunning = false
        Log.info("Engine stopped")
    }

    /// Creates a viewport with the engine as delegate
    @discardableResult
    public func createViewport(name: String, config: ViewportConfig = ViewportConfig()) -> Viewport
    {
        Log.info("Creating viewport: \(name)")
        return viewportManager.createViewport(
            name: name,
            delegate: self,
            eventDelegate: self
        )
    }

    /// Gets a viewport by ID
    public func getViewport(id: UUID) -> Viewport? {
        return viewportManager.getViewport(id: id)
    }

    /// Gets all registered viewports
    public func getAllViewports() -> [Viewport] {
        return viewportManager.getAllViewports()
    }

    /// Gets the active viewport
    public func getActiveViewport() -> Viewport? {
        return viewportManager.getActiveViewport()
    }

    /// Sets the active viewport
    public func setActiveViewport(id: UUID) {
        Log.debug("Setting active viewport: \(id)")
        viewportManager.setActiveViewport(id: id)
    }

    /// Removes a viewport
    public func removeViewport(id: UUID) {
        Log.info("Removing viewport: \(id)")
        viewportManager.removeViewport(id: id)
    }

    /// Gets view for a viewport
    @MainActor
    public func getViewportView(for id: UUID) -> ViewportView? {
        return viewportManager.getViewportView(for: id)
    }

    /// Gets view for the active viewport
    @MainActor
    public func getActiveViewportView() -> ViewportView? {
        return viewportManager.getActiveViewportView()
    }

    /// Access to the world
    public func getWorld() -> World {
        return world
    }
}

// NOTE: - ViewportDelegate Implementation
extension NaughtyEngine: ViewportDelegate {
    public func start(_ viewport: Viewport, _ view: MTKView) {
        Log.info("Viewport started: \(viewport.name)")
    }

    public func draw(_ viewport: Viewport, _ view: MTKView) {
        // Called every frame - just render without extra logic
    }

    public func resize(_ viewport: Viewport, to size: vec2f) {
        Log.debug("Viewport \(viewport.name) resized to: \(size)")
    }
}

// NOTE: - ViewportEventDelegate Implementation
extension NaughtyEngine: ViewportEventDelegate {
    // Pointer events
    public func pointerDown(_ viewport: Viewport, position: vec2f, button: Int) {
        Log.debug("Pointer down: \(position), button: \(button)")
    }

    public func pointerMoved(_ viewport: Viewport, position: vec2f) {
        Log.debug("Pointer moved: \(position)")
    }

    public func pointerUp(_ viewport: Viewport, position: vec2f, button: Int) {
        Log.debug("Pointer up: \(position), button: \(button)")
    }

    // Gesture events
    public func panGesture(
        _ viewport: Viewport,
        translation: vec2f,
        velocity: vec2f,
        position: vec2f,
        state: GestureState
    ) {
        Log.debug(
            "Pan gesture: translation \(translation), velocity \(velocity), position \(position), state \(state)"
        )
    }

    public func pinchGesture(
        _ viewport: Viewport,
        scale: Float,
        position: vec2f,
        state: GestureState
    ) {
        Log.debug("Pinch gesture: scale \(scale), position \(position), state \(state)")
    }

    public func rotationGesture(
        _ viewport: Viewport,
        angle: Float,
        position: vec2f,
        state: GestureState
    ) {
        Log.debug("Rotation gesture: angle \(angle), position \(position), state \(state)")
    }

    // Keyboard events
    public func keyDown(
        _ viewport: Viewport,
        keyCode: UInt,
        characters: String,
        modifiers: Int
    ) {
        Log.debug("Key down: \(keyCode), characters: \(characters), modifiers: \(modifiers)")
    }

    public func keyUp(
        _ viewport: Viewport,
        keyCode: UInt,
        characters: String,
        modifiers: Int
    ) {
        Log.debug("Key up: \(keyCode), characters: \(characters), modifiers: \(modifiers)")
    }
}
