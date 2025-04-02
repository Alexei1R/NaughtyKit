// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation
import MetalKit

public enum GestureState {
    case began
    case changed
    case ended
    case cancelled
}

public protocol ViewportDelegate: AnyObject {
    func start(_ viewport: Viewport, _ view: MTKView)
    func draw(_ viewport: Viewport, _ view: MTKView)
    func resize(_ viewport: Viewport, to size: vec2f)
}

extension ViewportDelegate {
    public func start(_ viewport: Viewport, _ view: MTKView) {}
    public func draw(_ viewport: Viewport, _ view: MTKView) {}
    public func resize(_ viewport: Viewport, to size: vec2f) {}
}

public protocol ViewportEventDelegate: AnyObject {
    // Common pointer events
    func pointerDown(_ viewport: Viewport, position: vec2f, button: Int)
    func pointerMoved(_ viewport: Viewport, position: vec2f)
    func pointerUp(_ viewport: Viewport, position: vec2f, button: Int)

    // Gesture events
    func panGesture(
        _ viewport: Viewport, translation: vec2f, velocity: vec2f, position: vec2f,
        state: GestureState)
    func pinchGesture(_ viewport: Viewport, scale: Float, position: vec2f, state: GestureState)
    func rotationGesture(_ viewport: Viewport, angle: Float, position: vec2f, state: GestureState)

    // Keyboard events
    func keyDown(_ viewport: Viewport, keyCode: UInt, characters: String, modifiers: Int)
    func keyUp(_ viewport: Viewport, keyCode: UInt, characters: String, modifiers: Int)
}

extension ViewportEventDelegate {
    public func pointerDown(_ viewport: Viewport, position: vec2f, button: Int) {}
    public func pointerMoved(_ viewport: Viewport, position: vec2f) {}
    public func pointerUp(_ viewport: Viewport, position: vec2f, button: Int) {}

    public func panGesture(
        _ viewport: Viewport, translation: vec2f, velocity: vec2f, position: vec2f,
        state: GestureState
    ) {}
    public func pinchGesture(
        _ viewport: Viewport, scale: Float, position: vec2f, state: GestureState
    ) {}
    public func rotationGesture(
        _ viewport: Viewport, angle: Float, position: vec2f, state: GestureState
    ) {}

    public func keyDown(_ viewport: Viewport, keyCode: UInt, characters: String, modifiers: Int) {}
    public func keyUp(_ viewport: Viewport, keyCode: UInt, characters: String, modifiers: Int) {}
}

#if os(iOS)
    import UIKit

    @MainActor
    public protocol TouchEventDelegate: AnyObject {
        func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView)
        func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView)
        func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView)
        func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView)
    }

    @MainActor
    public struct PositionNormalizer {
        static func normalizePosition(_ point: CGPoint, in view: UIView) -> vec2f {
            return vec2f(
                x: Float(point.x / view.bounds.width), y: Float(point.y / view.bounds.height))
        }

        static func normalizeVector(_ vector: vec2f, in view: UIView) -> vec2f {
            return vec2f(
                x: vector.x / Float(view.bounds.width), y: vector.y / Float(view.bounds.height))
        }

        static func denormalizePosition(_ position: vec2f, in view: UIView) -> CGPoint {
            return CGPoint(
                x: CGFloat(position.x) * view.bounds.width,
                y: CGFloat(position.y) * view.bounds.height)
        }
    }

#else
    import AppKit

    @MainActor
    public protocol MouseEventDelegate: AnyObject {
        func mouseDown(with event: NSEvent, in view: NSView)
        func mouseDragged(with event: NSEvent, in view: NSView)
        func mouseUp(with event: NSEvent, in view: NSView)
        func rightMouseDown(with event: NSEvent, in view: NSView)
        func rightMouseDragged(with event: NSEvent, in view: NSView)
        func rightMouseUp(with event: NSEvent, in view: NSView)
        func scrollWheel(with event: NSEvent, in view: NSView)
        func keyDown(with event: NSEvent, in view: NSView)
        func keyUp(with event: NSEvent, in view: NSView)
        func flagsChanged(with event: NSEvent, in view: NSView)
    }

    @MainActor
    public struct PositionNormalizer {
        static func normalizePosition(_ point: NSPoint, in view: NSView) -> vec2f {
            return vec2f(
                x: Float(point.x / view.bounds.width), y: Float(point.y / view.bounds.height))
        }

        static func normalizeVector(_ vector: vec2f, in view: NSView) -> vec2f {
            return vec2f(
                x: vector.x / Float(view.bounds.width), y: vector.y / Float(view.bounds.height))
        }

        static func denormalizePosition(_ position: vec2f, in view: NSView) -> NSPoint {
            return NSPoint(
                x: CGFloat(position.x) * view.bounds.width,
                y: CGFloat(position.y) * view.bounds.height)
        }
    }
#endif

