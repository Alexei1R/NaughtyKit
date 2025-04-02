// Copyright (c) 2025 The Noughy Fox
// MIT License - https://opensource.org/licenses/MIT

import Foundation
import MetalKit
import SwiftUI

public final class NaughtyEngine {
    private var isRunning: Bool = false
    private let viewportManager: ViewportManager
    private let world: World

    public init() {
        self.viewportManager = ViewportManager()
        self.world = World()
        print("NaughtyEngine initialized")
    }

    public func start() {
        guard !isRunning else {
            print("Engine is already running")
            return
        }

        isRunning = true
        print("Engine started")
    }

    public func stop() {
        guard isRunning else {
            print("Engine is not running")
            return
        }

        isRunning = false
        print("Engine stopped")
    }

    @discardableResult
    public func createViewport(name: String, config: ViewportConfig = ViewportConfig()) -> Viewport {
        print("Creating viewport: \(name)")
        return viewportManager.createViewport(
            name: name,
            delegate: self,
            eventDelegate: self
        )
    }

    public func getViewport(id: UUID) -> Viewport? {
        return viewportManager.getViewport(id: id)
    }

    public func getAllViewports() -> [Viewport] {
        return viewportManager.getAllViewports()
    }

    public func getActiveViewport() -> Viewport? {
        return viewportManager.getActiveViewport()
    }

    public func setActiveViewport(id: UUID) {
        viewportManager.setActiveViewport(id: id)
    }

    public func removeViewport(id: UUID) {
        viewportManager.removeViewport(id: id)
    }

    @MainActor
    public func getViewportView(for id: UUID) -> ViewportView? {
        return viewportManager.getViewportView(for: id)
    }

    @MainActor
    public func getActiveViewportView() -> ViewportView? {
        return viewportManager.getActiveViewportView()
    }

    public func getWorld() -> World {
        return world
    }
}

//NOTE: ViewportDelegate Implementation
extension NaughtyEngine: ViewportDelegate {
    public func start(_ viewport: Viewport, _ view: MTKView) {
        print("Viewport '\(viewport.name)' initialized")
    }

    public func draw(_ viewport: Viewport, _ view: MTKView) {
        // Called every frame - render without extra logic
    }

    public func resize(_ viewport: Viewport, to size: vec2f) {
        print("Viewport '\(viewport.name)' resized: \(size.x) × \(size.y)")
    }
}

//NOTE: ViewportEventDelegate Implementation
extension NaughtyEngine: ViewportEventDelegate {
    // Mouse/touch events
    public func cursorDown(_ viewport: Viewport, position: vec2f, button: Int) {
        print("Input: Button \(button) down at (\(position.x), \(position.y))")
    }

    public func cursorMoved(_ viewport: Viewport, position: vec2f) {
        print("Input: Cursor moved to (\(position.x), \(position.y))")
    }

    public func cursorUp(_ viewport: Viewport, position: vec2f, button: Int) {
        print("Input: Button \(button) up at (\(position.x), \(position.y))")
    }

    // Gesture events
    public func dragGesture(
        _ viewport: Viewport,
        translation: vec2f,
        velocity: vec2f,
        position: vec2f,
        state: GestureState
    ) {
        print("Gesture: Drag \(state) - moved \(translation.x), \(translation.y)")
    }

    public func zoomGesture(
        _ viewport: Viewport,
        scale: Float,
        position: vec2f,
        state: GestureState
    ) {
        print("Gesture: Zoom \(state) - scale \(scale)")
    }

    public func rotateGesture(
        _ viewport: Viewport,
        angle: Float,
        position: vec2f,
        state: GestureState
    ) {
        print("Gesture: Rotate \(state) - angle \(angle)")
    }

    // Keyboard event
    public func keyEvent(
        _ viewport: Viewport,
        keyCode: UInt,
        characters: String,
        modifiers: Int,
        isDown: Bool
    ) {
        let action = isDown ? "pressed" : "released"
        print("Keyboard: Key \(action) - code: \(keyCode), char: \(characters)")
    }
}
