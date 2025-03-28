// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#if os(iOS)
    import UIKit
    import MetalKit

    @MainActor
    extension ViewportCoordinator {
        @objc public func handlePanGesture(_ sender: UIPanGestureRecognizer) {
            guard let view = sender.view else { return }

            // Only process state changes we care about
            if sender.state != .began && sender.state != .changed && sender.state != .ended
                && sender.state != .cancelled
            {
                return
            }

            let location = sender.location(in: view)
            let velocity = sender.velocity(in: view)
            let translation = sender.translation(in: view)
            let state = stateToString(sender.state)

            // Get normalized position and vectors
            let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)
            let rawTranslation = vec2f(x: Float(translation.x), y: Float(translation.y))
            let normalizedTranslation = PositionNormalizer.normalizeVector(rawTranslation, in: view)
            let rawVelocity = vec2f(x: Float(velocity.x), y: Float(velocity.y))

            Log.info(
                "Drag: translation=(\(normalizedTranslation.x), \(normalizedTranslation.y)), "
                    + "velocity=(\(rawVelocity.x), \(rawVelocity.y)), "
                    + "position=(\(normalizedPosition.x), \(normalizedPosition.y)), "
                    + "state=\(state)")

            // Reset translation after handling
            if sender.state == .changed {
                sender.setTranslation(.zero, in: view)
            }

            // Update multi-touch state
            if sender.state == .began {
                if sender.numberOfTouches >= 2 {
                    multiTouchGestureActive = true
                }
            } else if sender.state == .ended || sender.state == .cancelled {
                if sender.numberOfTouches == 0 {
                    multiTouchGestureActive = false
                }
            }
        }

        @objc public func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
            guard let view = sender.view else { return }

            // Only process state changes we care about
            if sender.state != .began && sender.state != .changed && sender.state != .ended
                && sender.state != .cancelled
            {
                return
            }

            // Update multi-touch state
            if sender.state == .began {
                multiTouchGestureActive = true
            } else if sender.state == .ended || sender.state == .cancelled {
                if sender.numberOfTouches <= 1 {
                    multiTouchGestureActive = false
                }
            }

            let location = sender.location(in: view)
            let normalizedCenter = PositionNormalizer.normalizePosition(location, in: view)
            let state = stateToString(sender.state)

            Log.info(
                "Pinch: scale=\(Float(sender.scale)), " + "velocity=\(Float(sender.velocity)), "
                    + "center=(\(normalizedCenter.x), \(normalizedCenter.y)), " + "state=\(state)")

            if sender.state == .ended || sender.state == .cancelled {
                sender.scale = 1.0
            }
        }

        @objc public func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
            guard let view = sender.view else { return }

            // Only process state changes we care about
            if sender.state != .began && sender.state != .changed && sender.state != .ended
                && sender.state != .cancelled
            {
                return
            }

            // Update multi-touch state
            if sender.state == .began {
                multiTouchGestureActive = true
            } else if sender.state == .ended || sender.state == .cancelled {
                if sender.numberOfTouches <= 1 {
                    multiTouchGestureActive = false
                }
            }

            let location = sender.location(in: view)
            let normalizedCenter = PositionNormalizer.normalizePosition(location, in: view)
            let state = stateToString(sender.state)

            Log.info(
                "Rotation: angle=\(Float(sender.rotation)), "
                    + "velocity=\(Float(sender.velocity)), "
                    + "center=(\(normalizedCenter.x), \(normalizedCenter.y)), " + "state=\(state)")

            // Reset rotation when done
            if sender.state == .ended || sender.state == .cancelled {
                sender.rotation = 0
            }
        }
    }

    @MainActor
    extension ViewportCoordinator: TouchEventDelegate {
        public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
            if let allTouches = event?.allTouches {
                activeTouchCount = allTouches.count

                // Update multi-touch state
                if activeTouchCount >= 2 {
                    multiTouchGestureActive = true
                }
            }

            for touch in touches {
                let position = PositionNormalizer.normalizePosition(
                    touch.location(in: view), in: view)
                Log.info("Touch Began: position=(\(position.x), \(position.y))")
            }
        }

        public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
            if let allTouches = event?.allTouches {
                activeTouchCount = allTouches.count
            }

            // Only handle direct touch movement for single touch when no multi-touch is active
            if activeTouchCount == 1 && !multiTouchGestureActive {
                for touch in touches {
                    let position = PositionNormalizer.normalizePosition(
                        touch.location(in: view), in: view)
                    Log.info("Touch Moved: position=(\(position.x), \(position.y))")
                }
            }
        }

        public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
            for touch in touches {
                let position = PositionNormalizer.normalizePosition(
                    touch.location(in: view), in: view)
                Log.info("Touch Ended: position=(\(position.x), \(position.y))")
            }

            if let allTouches = event?.allTouches {
                activeTouchCount = allTouches.count

                // Reset multi-touch state when all touches end
                if allTouches.isEmpty {
                    activeTouchCount = 0
                    multiTouchGestureActive = false
                }
            }
        }

        public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView)
        {
            for touch in touches {
                let position = PositionNormalizer.normalizePosition(
                    touch.location(in: view), in: view)
                Log.info("Touch Cancelled: position=(\(position.x), \(position.y))")
            }

            activeTouchCount = 0
            multiTouchGestureActive = false
        }
    }
#else
    import AppKit
    import MetalKit

    @MainActor
    extension ViewportCoordinator {
        @objc public func handlePanGesture(_ sender: NSPanGestureRecognizer) {
            guard let view = sender.view else { return }

            // Only process state changes we care about
            if sender.state != .began && sender.state != .changed && sender.state != .ended
                && sender.state != .cancelled
            {
                return
            }

            let location = sender.location(in: view)
            let translation = sender.translation(in: view)
            let state = stateToString(sender.state)

            // Get normalized position and vectors
            let normalizedPosition = PositionNormalizer.normalizePosition(location, in: view)
            let rawTranslation = vec2f(x: Float(translation.x), y: Float(translation.y))
            let normalizedTranslation = PositionNormalizer.normalizeVector(rawTranslation, in: view)

            Log.info(
                "Drag: translation=(\(normalizedTranslation.x), \(normalizedTranslation.y)), "
                    + "position=(\(normalizedPosition.x), \(normalizedPosition.y)), "
                    + "state=\(state)")

            // Reset translation after handling
            if sender.state == .changed {
                sender.setTranslation(.zero, in: view)
            }

            // Update multi-gesture state
            if sender.state == .began {
                multiGestureActive = true
            } else if sender.state == .ended || sender.state == .cancelled {
                multiGestureActive = false
            }
        }

        @objc public func handleMagnificationGesture(_ sender: NSMagnificationGestureRecognizer) {
            guard let view = sender.view else { return }

            // Only process state changes we care about
            if sender.state != .began && sender.state != .changed && sender.state != .ended
                && sender.state != .cancelled
            {
                return
            }

            // Update multi-gesture state
            if sender.state == .began {
                multiGestureActive = true
            } else if sender.state == .ended || sender.state == .cancelled {
                multiGestureActive = false
            }

            let location = sender.location(in: view)
            let normalizedCenter = PositionNormalizer.normalizePosition(location, in: view)
            let state = stateToString(sender.state)

            Log.info(
                "Pinch: scale=\(Float(sender.magnification + 1.0)), "
                    + "center=(\(normalizedCenter.x), \(normalizedCenter.y)), "
                    + "state=\(state)")

            // Reset magnification when done
            if sender.state == .ended || sender.state == .cancelled {
                sender.magnification = 0.0
            }
        }

        @objc public func handleRotationGesture(_ sender: NSRotationGestureRecognizer) {
            guard let view = sender.view else { return }

            // Only process state changes we care about
            if sender.state != .began && sender.state != .changed && sender.state != .ended
                && sender.state != .cancelled
            {
                return
            }

            // Update multi-gesture state
            if sender.state == .began {
                multiGestureActive = true
            } else if sender.state == .ended || sender.state == .cancelled {
                multiGestureActive = false
            }

            let location = sender.location(in: view)
            let normalizedCenter = PositionNormalizer.normalizePosition(location, in: view)
            let state = stateToString(sender.state)

            // Convert to radians similar to iOS (negative because macOS rotation is clockwise)
            let rotationRadians = -Float(sender.rotation)

            Log.info(
                "Rotation: angle=\(rotationRadians), "
                    + "center=(\(normalizedCenter.x), \(normalizedCenter.y)), "
                    + "state=\(state)")

            // Reset rotation when done
            if sender.state == .ended || sender.state == .cancelled {
                sender.rotation = 0
            }
        }
    }

    @MainActor
    extension ViewportCoordinator: MouseEventDelegate {
        public func mouseDown(with event: NSEvent, in view: NSView) {
            isMouseDown = true
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)
            Log.info("Mouse Down: position=(\(position.x), \(position.y))")
        }

        public func mouseDragged(with event: NSEvent, in view: NSView) {
            if isMouseDown && !multiGestureActive {
                let viewLocation = view.convert(event.locationInWindow, from: nil)
                let position = PositionNormalizer.normalizePosition(viewLocation, in: view)
                Log.info("Mouse Dragged: position=(\(position.x), \(position.y))")
            }
        }

        public func mouseUp(with event: NSEvent, in view: NSView) {
            isMouseDown = false
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)
            Log.info("Mouse Up: position=(\(position.x), \(position.y))")
        }

        public func rightMouseDown(with event: NSEvent, in view: NSView) {
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)
            Log.info("Right Mouse Down: position=(\(position.x), \(position.y))")
        }

        public func rightMouseDragged(with event: NSEvent, in view: NSView) {
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)
            Log.info("Right Mouse Dragged: position=(\(position.x), \(position.y))")
        }

        public func rightMouseUp(with event: NSEvent, in view: NSView) {
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)
            Log.info("Right Mouse Up: position=(\(position.x), \(position.y))")
        }

        public func scrollWheel(with event: NSEvent, in view: NSView) {
            let viewLocation = view.convert(event.locationInWindow, from: nil)
            let position = PositionNormalizer.normalizePosition(viewLocation, in: view)
            let scrollDelta = vec2f(
                x: Float(event.scrollingDeltaX), y: Float(event.scrollingDeltaY))

            Log.info(
                "Scroll Wheel: delta=(\(scrollDelta.x), \(scrollDelta.y)), position=(\(position.x), \(position.y))"
            )
        }

        // NOTE: - Keyboard event handling
        public func keyDown(with event: NSEvent, in view: NSView) {
            let characters = event.charactersIgnoringModifiers ?? ""
            let keyCode = event.keyCode
            let modifiers = getModifierFlagsString(event.modifierFlags)

            Log.info(
                "Key Down: characters='\(characters)', keyCode=\(keyCode), modifiers=[\(modifiers)]"
            )

            updateModifierKeyStates(flags: event.modifierFlags)
        }

        public func keyUp(with event: NSEvent, in view: NSView) {
            let characters = event.charactersIgnoringModifiers ?? ""
            let keyCode = event.keyCode
            let modifiers = getModifierFlagsString(event.modifierFlags)

            Log.info(
                "Key Up: characters='\(characters)', keyCode=\(keyCode), modifiers=[\(modifiers)]")

            updateModifierKeyStates(flags: event.modifierFlags)
        }

        public func flagsChanged(with event: NSEvent, in view: NSView) {
            let modifiers = getModifierFlagsString(event.modifierFlags)
            let keyCode = event.keyCode

            // Determine which modifier key changed
            var keyName = "unknown"
            switch keyCode {
            case 56: keyName = "shift"
            case 59, 62: keyName = "control"
            case 58, 61: keyName = "option"
            case 55, 54: keyName = "command"
            case 63: keyName = "function"
            default: break
            }

            Log.info(
                "Modifier Key Changed: key=\(keyName), keyCode=\(keyCode), modifiers=[\(modifiers)]"
            )

            updateModifierKeyStates(flags: event.modifierFlags)
        }
    }
#endif
