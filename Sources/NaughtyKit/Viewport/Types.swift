// Copyright (c) 2025 The Noughy Fox
// https://opensource.org/licenses/MIT

import Foundation
import MetalKit

public enum GestureState {
    case began, changed, ended, cancelled
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
    // Mouse/touch events
    func cursorDown(_ viewport: Viewport, position: vec2f, button: Int)
    func cursorMoved(_ viewport: Viewport, position: vec2f)
    func cursorUp(_ viewport: Viewport, position: vec2f, button: Int)

    // Gesture events
    func dragGesture(_ viewport: Viewport, translation: vec2f, velocity: vec2f, position: vec2f, state: GestureState)
    func zoomGesture(_ viewport: Viewport, scale: Float, position: vec2f, state: GestureState)
    func rotateGesture(_ viewport: Viewport, angle: Float, position: vec2f, state: GestureState)

    // Keyboard event
    func keyEvent(_ viewport: Viewport, keyCode: UInt, characters: String, modifiers: Int, isDown: Bool)
}

extension ViewportEventDelegate {
    public func cursorDown(_ viewport: Viewport, position: vec2f, button: Int) {}
    public func cursorMoved(_ viewport: Viewport, position: vec2f) {}
    public func cursorUp(_ viewport: Viewport, position: vec2f, button: Int) {}
    
    public func dragGesture(_ viewport: Viewport, translation: vec2f, velocity: vec2f, position: vec2f, state: GestureState) {}
    public func zoomGesture(_ viewport: Viewport, scale: Float, position: vec2f, state: GestureState) {}
    public func rotateGesture(_ viewport: Viewport, angle: Float, position: vec2f, state: GestureState) {}
    
    public func keyEvent(_ viewport: Viewport, keyCode: UInt, characters: String, modifiers: Int, isDown: Bool) {}
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
            return vec2f(x: Float(point.x / view.bounds.width), y: Float(point.y / view.bounds.height))
        }

        static func normalizeVector(_ vector: vec2f, in view: UIView) -> vec2f {
            return vec2f(x: vector.x / Float(view.bounds.width), y: vector.y / Float(view.bounds.height))
        }

        static func denormalizePosition(_ position: vec2f, in view: UIView) -> CGPoint {
            return CGPoint(x: CGFloat(position.x) * view.bounds.width, y: CGFloat(position.y) * view.bounds.height)
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
        func keyEvent(with event: NSEvent, in view: NSView, isDown: Bool)
        func flagsChanged(with event: NSEvent, in view: NSView)
    }

    @MainActor
    public struct PositionNormalizer {
        static func normalizePosition(_ point: NSPoint, in view: NSView) -> vec2f {
            return vec2f(x: Float(point.x / view.bounds.width), y: Float(point.y / view.bounds.height))
        }

        static func normalizeVector(_ vector: vec2f, in view: NSView) -> vec2f {
            return vec2f(x: vector.x / Float(view.bounds.width), y: vector.y / Float(view.bounds.height))
        }

        static func denormalizePosition(_ position: vec2f, in view: NSView) -> NSPoint {
            return NSPoint(x: CGFloat(position.x) * view.bounds.width, y: CGFloat(position.y) * view.bounds.height)
        }
    }
#endif
