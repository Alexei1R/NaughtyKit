// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation
import MetalKit

@MainActor
public class ViewportCoordinator: NSObject, MTKViewDelegate {
    private weak var viewport: Viewport?
    private let renderer: ViewportRenderer

    #if os(iOS)
        internal var activeTouchCount: Int = 0
        internal var multiTouchGestureActive: Bool = false
        internal var lastTouchLocations: [UITouch: CGPoint] = [:]
    #else
        internal var isMouseDown: Bool = false
        internal var multiGestureActive: Bool = false
        internal var shiftKeyDown: Bool = false
        internal var controlKeyDown: Bool = false
        internal var optionKeyDown: Bool = false
        internal var commandKeyDown: Bool = false
    #endif

    public init(viewport: Viewport) {
        self.viewport = viewport
        self.renderer = ViewportRenderer(viewport: viewport)
        super.init()
    }

    public func draw(in view: MTKView) {
        renderer.draw(in: view)
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.resize(to: size)
    }

    #if os(iOS)
        internal func convertToGestureState(_ state: UIGestureRecognizer.State) -> GestureState {
            switch state {
            case .began: return .began
            case .changed: return .changed
            case .ended: return .ended
            case .cancelled: return .cancelled
            default: return .cancelled
            }
        }
    #else
        internal func convertToGestureState(_ state: NSGestureRecognizer.State) -> GestureState {
            switch state {
            case .began: return .began
            case .changed: return .changed
            case .ended: return .ended
            case .cancelled: return .cancelled
            default: return .cancelled
            }
        }
    #endif
}

#if os(iOS)
    import UIKit

    @MainActor
    extension ViewportCoordinator: UIGestureRecognizerDelegate {
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

            // Never allow pan with pinch or rotation
            if gestureRecognizer is UIPanGestureRecognizer
                && (otherGestureRecognizer is UIPinchGestureRecognizer
                    || otherGestureRecognizer is UIRotationGestureRecognizer)
            {
                return false
            }

            return false
        }

        @objc public func handlePanGesture(_ sender: UIPanGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            let location = sender.location(in: view)
            let velocity = sender.velocity(in: view)
            let translation = sender.translation(in: view)

            let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)
            let normalizedVelocity = vec2f(x: Float(velocity.x), y: Float(velocity.y))
            let rawTranslation = vec2f(x: Float(translation.x), y: Float(translation.y))
            let normalizedTranslation = PositionNormalizer.normalizeVector(rawTranslation, in: view)

            viewport.eventDelegate?.panGesture(
                viewport,
                translation: normalizedTranslation,
                velocity: normalizedVelocity,
                position: normalizedPosition,
                state: convertToGestureState(sender.state)
            )

            if sender.state == .changed {
                sender.setTranslation(.zero, in: view)
            }

            updateMultiTouchState(for: sender)
        }

        @objc public func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            let location = sender.location(in: view)
            let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)

            viewport.eventDelegate?.pinchGesture(
                viewport,
                scale: Float(sender.scale),
                position: normalizedPosition,
                state: convertToGestureState(sender.state)
            )

            if sender.state == .ended || sender.state == .cancelled {
                sender.scale = 1.0
            }

            updateMultiTouchState(for: sender)
        }

        @objc public func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            let location = sender.location(in: view)
            let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)

            viewport.eventDelegate?.rotationGesture(
                viewport,
                angle: Float(sender.rotation),
                position: normalizedPosition,
                state: convertToGestureState(sender.state)
            )

            if sender.state == .ended || sender.state == .cancelled {
                sender.rotation = 0
            }

            updateMultiTouchState(for: sender)
        }

        @objc public func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            if sender.state == .ended {
                let location = sender.location(in: view)
                let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)

                // Determine swipe direction and velocity
                var direction = vec2f(x: 0, y: 0)

                switch sender.direction {
                case .right: direction.x = 1
                case .left: direction.x = -1
                case .up: direction.y = -1
                case .down: direction.y = 1
                default: break
                }

                // Use pan gesture with fixed velocity for swipes
                viewport.eventDelegate?.panGesture(
                    viewport,
                    translation: direction * 0.2,
                    velocity: direction * 1000,
                    position: normalizedPosition,
                    state: .ended
                )
            }
        }

        @objc public func handleTapGesture(_ sender: UITapGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            if sender.state == .ended {
                let location = sender.location(in: view)
                let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)

                viewport.eventDelegate?.pointerDown(
                    viewport, position: normalizedPosition, button: 0)
                viewport.eventDelegate?.pointerUp(viewport, position: normalizedPosition, button: 0)
            }
        }

        @objc public func handleDoubleTapGesture(_ sender: UITapGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            if sender.state == .ended {
                let location = sender.location(in: view)
                let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)

                viewport.eventDelegate?.pointerDown(
                    viewport, position: normalizedPosition, button: 2)
                viewport.eventDelegate?.pointerUp(viewport, position: normalizedPosition, button: 2)
            }
        }

        @objc public func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            let location = sender.location(in: view)
            let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)

            switch sender.state {
            case .began:
                viewport.eventDelegate?.pointerDown(
                    viewport, position: normalizedPosition, button: 1)
            case .ended, .cancelled:
                viewport.eventDelegate?.pointerUp(viewport, position: normalizedPosition, button: 1)
            default:
                break
            }
        }

        private func updateMultiTouchState(for gestureRecognizer: UIGestureRecognizer) {
            if gestureRecognizer.state == .began {
                if let pinchGesture = gestureRecognizer as? UIPinchGestureRecognizer,
                    pinchGesture.numberOfTouches >= 2
                {
                    multiTouchGestureActive = true
                } else if let rotationGesture = gestureRecognizer as? UIRotationGestureRecognizer,
                    rotationGesture.numberOfTouches >= 2
                {
                    multiTouchGestureActive = true
                } else if let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
                    panGesture.numberOfTouches >= 2
                {
                    multiTouchGestureActive = true
                }
            } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
                if activeTouchCount <= 1 {
                    multiTouchGestureActive = false
                }
            }
        }
    }

    @MainActor
    extension ViewportCoordinator: TouchEventDelegate {
        public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
            guard let viewport = self.viewport else { return }

            if let allTouches = event?.allTouches {
                activeTouchCount = allTouches.count
                multiTouchGestureActive = activeTouchCount >= 2
            }

            for touch in touches {
                let location = touch.location(in: view)
                lastTouchLocations[touch] = location

                // Only send pointer events for single touches when not in multi-touch mode
                if activeTouchCount == 1 {
                    let position = PositionNormalizer.normalizePosition(location, in: view)
                    viewport.eventDelegate?.pointerDown(viewport, position: position, button: 0)
                }
            }
        }

        public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
            guard let viewport = self.viewport else { return }

            if let allTouches = event?.allTouches {
                activeTouchCount = allTouches.count
            }

            if activeTouchCount == 1 && !multiTouchGestureActive {
                for touch in touches {
                    let location = touch.location(in: view)
                    lastTouchLocations[touch] = location
                    let position = PositionNormalizer.normalizePosition(location, in: view)
                    viewport.eventDelegate?.pointerMoved(viewport, position: position)
                }
            }
        }

        public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
            guard let viewport = self.viewport else { return }

            for touch in touches {
                let location = touch.location(in: view)
                let position = PositionNormalizer.normalizePosition(location, in: view)

                if activeTouchCount <= 1 {
                    viewport.eventDelegate?.pointerUp(viewport, position: position, button: 0)
                }

                lastTouchLocations.removeValue(forKey: touch)
            }

            if let allTouches = event?.allTouches {
                activeTouchCount = allTouches.count

                if allTouches.isEmpty {
                    activeTouchCount = 0
                    multiTouchGestureActive = false
                }
            }
        }

        public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView)
        {
            guard let viewport = self.viewport else { return }

            for touch in touches {
                let location = touch.location(in: view)
                let position = PositionNormalizer.normalizePosition(location, in: view)
                viewport.eventDelegate?.pointerUp(viewport, position: position, button: 0)
                lastTouchLocations.removeValue(forKey: touch)
            }

            activeTouchCount = 0
            multiTouchGestureActive = false
        }
    }

#else
    import AppKit

    @MainActor
    extension ViewportCoordinator {
        @objc public func handlePanGesture(_ sender: NSPanGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            let location = sender.location(in: view)
            let translation = sender.translation(in: view)

            let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)
            let rawTranslation = vec2f(x: Float(translation.x), y: Float(translation.y))
            let normalizedTranslation = PositionNormalizer.normalizeVector(rawTranslation, in: view)

            viewport.eventDelegate?.panGesture(
                viewport,
                translation: normalizedTranslation,
                velocity: vec2f(x: 0, y: 0),
                position: normalizedPosition,
                state: convertToGestureState(sender.state)
            )

            if sender.state == .changed {
                sender.setTranslation(.zero, in: view)
            }

            multiGestureActive =
                sender.state == .began || (sender.state != .ended && sender.state != .cancelled)
        }

        @objc public func handleMagnificationGesture(_ sender: NSMagnificationGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            let location = sender.location(in: view)
            let normalizedCenter = PositionNormalizer.normalizePosition(location, in: view)

            viewport.eventDelegate?.pinchGesture(
                viewport,
                scale: Float(sender.magnification + 1.0),
                position: normalizedCenter,
                state: convertToGestureState(sender.state)
            )

            if sender.state == .ended || sender.state == .cancelled {
                sender.magnification = 0.0
            }

            multiGestureActive =
                sender.state == .began || (sender.state != .ended && sender.state != .cancelled)
        }

        @objc public func handleRotationGesture(_ sender: NSRotationGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            let location = sender.location(in: view)
            let normalizedCenter = PositionNormalizer.normalizePosition(location, in: view)
            let rotationRadians = -Float(sender.rotation)

            viewport.eventDelegate?.rotationGesture(
                viewport,
                angle: rotationRadians,
                position: normalizedCenter,
                state: convertToGestureState(sender.state)
            )

            if sender.state == .ended || sender.state == .cancelled {
                sender.rotation = 0
            }

            multiGestureActive =
                sender.state == .began || (sender.state != .ended && sender.state != .cancelled)
        }

        @objc public func handleClickGesture(_ sender: NSClickGestureRecognizer) {
            guard let view = sender.view, let viewport = self.viewport else { return }

            if sender.state == .ended {
                let location = sender.location(in: view)
                let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)

                viewport.eventDelegate?.pointerDown(
                    viewport, position: normalizedPosition, button: 0)
                viewport.eventDelegate?.pointerUp(viewport, position: normalizedPosition, button: 0)
            }
        }
    }

    @MainActor
    extension ViewportCoordinator: MouseEventDelegate {
        public func mouseDown(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            isMouseDown = true
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)

            viewport.eventDelegate?.pointerDown(viewport, position: position, button: 0)
        }

        public func mouseDragged(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            if isMouseDown && !multiGestureActive {
                let viewLocation = view.convert(event.locationInWindow, from: nil)
                let position = PositionNormalizer.normalizePosition(viewLocation, in: view)

                viewport.eventDelegate?.pointerMoved(viewport, position: position)
            }
        }

        public func mouseUp(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            isMouseDown = false
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)

            viewport.eventDelegate?.pointerUp(viewport, position: position, button: 0)
        }

        public func rightMouseDown(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)

            viewport.eventDelegate?.pointerDown(viewport, position: position, button: 1)
        }

        public func rightMouseDragged(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)

            viewport.eventDelegate?.pointerMoved(viewport, position: position)
        }

        public func rightMouseUp(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)

            viewport.eventDelegate?.pointerUp(viewport, position: position, button: 1)
        }

        public func scrollWheel(with event: NSEvent, in view: NSView) {
            // Handle scroll wheel if needed
        }

        public func keyDown(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            let characters = event.charactersIgnoringModifiers ?? ""
            let keyCode = event.keyCode
            let modifiers = event.modifierFlags.rawValue

            viewport.eventDelegate?.keyDown(
                viewport, keyCode: UInt(keyCode), characters: characters, modifiers: Int(modifiers))

            updateModifierKeyStates(flags: event.modifierFlags)
        }

        public func keyUp(with event: NSEvent, in view: NSView) {
            guard let viewport = self.viewport else { return }

            let characters = event.charactersIgnoringModifiers ?? ""
            let keyCode = event.keyCode
            let modifiers = event.modifierFlags.rawValue

            viewport.eventDelegate?.keyUp(
                viewport, keyCode: UInt(keyCode), characters: characters, modifiers: Int(modifiers))

            updateModifierKeyStates(flags: event.modifierFlags)
        }

        public func flagsChanged(with event: NSEvent, in view: NSView) {
            updateModifierKeyStates(flags: event.modifierFlags)
        }

        internal func updateModifierKeyStates(flags: NSEvent.ModifierFlags) {
            shiftKeyDown = flags.contains(.shift)
            controlKeyDown = flags.contains(.control)
            optionKeyDown = flags.contains(.option)
            commandKeyDown = flags.contains(.command)
        }
    }
#endif

