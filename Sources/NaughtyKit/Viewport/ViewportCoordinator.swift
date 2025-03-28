// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation
import MetalKit

#if os(iOS)
    import UIKit

    @MainActor
    public class ViewportCoordinator: NSObject, MTKViewDelegate, UIGestureRecognizerDelegate {
        internal var activeTouchCount: Int = 0
        internal var multiTouchGestureActive: Bool = false

        private let renderer: ViewportRenderer

        public override init() {
            renderer = ViewportRenderer()
            super.init()
            print("ViewportCoordinator initialized")
        }

        public func draw(in view: MTKView) {
            renderer.draw(in: view)
        }

        public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            print("MTKView size changed to: \(size)")
            renderer.resize(to: size)
        }

        internal func stateToString(_ state: UIGestureRecognizer.State) -> String {
            switch state {
            case .began: return "began"
            case .changed: return "changed"
            case .ended: return "ended"
            case .cancelled: return "cancelled"
            case .failed: return "failed"
            case .possible: return "possible"
            @unknown default: return "unknown"
            }
        }

        public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer is UIPanGestureRecognizer && activeTouchCount == 1
                && !multiTouchGestureActive
            {
                return true
            }

            if gestureRecognizer is UIPinchGestureRecognizer
                || gestureRecognizer is UIRotationGestureRecognizer
            {
                return true
            }

            return activeTouchCount <= 1 && !multiTouchGestureActive
        }

        public func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            // Allow pinch and rotation to work together
            if (gestureRecognizer is UIPinchGestureRecognizer
                && otherGestureRecognizer is UIRotationGestureRecognizer)
                || (gestureRecognizer is UIRotationGestureRecognizer
                    && otherGestureRecognizer is UIPinchGestureRecognizer)
            {
                return true
            }

            // Don't allow pan to interfere with pinch/rotation
            if gestureRecognizer is UIPanGestureRecognizer
                && (otherGestureRecognizer is UIPinchGestureRecognizer
                    || otherGestureRecognizer is UIRotationGestureRecognizer)
            {
                return false
            }

            return false
        }
    }

#else
    import AppKit

    @MainActor
    public class ViewportCoordinator: NSObject, MTKViewDelegate {
        internal var isMouseDown: Bool = false
        internal var multiGestureActive: Bool = false

        internal var shiftKeyDown: Bool = false
        internal var controlKeyDown: Bool = false
        internal var optionKeyDown: Bool = false
        internal var commandKeyDown: Bool = false

        // Renderer for drawing operations
        private let renderer: ViewportRenderer

        public override init() {
            renderer = ViewportRenderer()
            super.init()
            print("ViewportCoordinator initialized")
        }

        public func draw(in view: MTKView) {
            renderer.draw(in: view)
        }

        public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            print("MTKView size changed to: \(size)")
            renderer.resize(to: size)
        }

        internal func stateToString(_ state: NSGestureRecognizer.State) -> String {
            switch state {
            case .began: return "began"
            case .changed: return "changed"
            case .ended: return "ended"
            case .cancelled: return "cancelled"
            case .failed: return "failed"
            case .possible: return "possible"
            @unknown default: return "unknown"
            }
        }

        internal func getModifierFlagsString(_ flags: NSEvent.ModifierFlags) -> String {
            var modifiers: [String] = []

            if flags.contains(.shift) { modifiers.append("shift") }
            if flags.contains(.control) { modifiers.append("control") }
            if flags.contains(.option) { modifiers.append("option") }
            if flags.contains(.command) { modifiers.append("command") }
            if flags.contains(.function) { modifiers.append("function") }
            if flags.contains(.capsLock) { modifiers.append("capsLock") }

            return modifiers.joined(separator: "+")
        }

        internal func updateModifierKeyStates(flags: NSEvent.ModifierFlags) {
            shiftKeyDown = flags.contains(.shift)
            controlKeyDown = flags.contains(.control)
            optionKeyDown = flags.contains(.option)
            commandKeyDown = flags.contains(.command)
        }
    }
#endif
