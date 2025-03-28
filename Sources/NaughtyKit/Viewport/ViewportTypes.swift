// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation

#if os(iOS)
    import UIKit

    // NOTE: - iOS Protocol Definitions
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
                x: Float(point.x / view.bounds.width),
                y: Float(point.y / view.bounds.height)
            )
        }

        static func normalizeVector(_ vector: vec2f, in view: UIView) -> vec2f {
            return vec2f(
                x: vector.x / Float(view.bounds.width),
                y: vector.y / Float(view.bounds.height)
            )
        }
    }
#else
    import AppKit

    // NOTE: - macOS Protocol Definitions
    @MainActor
    public protocol MouseEventDelegate: AnyObject {
        // Mouse events
        func mouseDown(with event: NSEvent, in view: NSView)
        func mouseDragged(with event: NSEvent, in view: NSView)
        func mouseUp(with event: NSEvent, in view: NSView)
        func rightMouseDown(with event: NSEvent, in view: NSView)
        func rightMouseDragged(with event: NSEvent, in view: NSView)
        func rightMouseUp(with event: NSEvent, in view: NSView)
        func scrollWheel(with event: NSEvent, in view: NSView)

        // Keyboard events
        func keyDown(with event: NSEvent, in view: NSView)
        func keyUp(with event: NSEvent, in view: NSView)
        func flagsChanged(with event: NSEvent, in view: NSView)
    }

    @MainActor
    public struct PositionNormalizer {
        static func normalizePosition(_ point: NSPoint, in view: NSView) -> vec2f {
            // In macOS, origin is bottom-left, convert to normalized coordinates
            return vec2f(
                x: Float(point.x / view.bounds.width),
                y: Float(point.y / view.bounds.height)
            )
        }

        static func normalizeVector(_ vector: vec2f, in view: NSView) -> vec2f {
            return vec2f(
                x: vector.x / Float(view.bounds.width),
                y: vector.y / Float(view.bounds.height)
            )
        }
    }
#endif
