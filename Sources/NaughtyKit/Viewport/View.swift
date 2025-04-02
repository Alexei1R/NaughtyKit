// Copyright (c) 2025 The Noughy Fox
// https://opensource.org/licenses/MIT

import Combine
import MetalKit
import SwiftUI

#if os(iOS)
    import UIKit

    public struct ViewportView: UIViewRepresentable {
        private let coordinator: ViewportCoordinator

        public init(coordinator: ViewportCoordinator) {
            self.coordinator = coordinator
        }

        @MainActor
        public func makeUIView(context: Context) -> TouchEnabledMTKView {
            let view = TouchEnabledMTKView()

            //NOTE: Setup Metal device and view properties
            if let device = MTLCreateSystemDefaultDevice() {
                view.device = device
            }

            view.delegate = coordinator
            view.touchDelegate = coordinator
            view.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            view.preferredFramesPerSecond = 60
            view.isPaused = false
            view.enableSetNeedsDisplay = false
            view.isMultipleTouchEnabled = true
            view.colorPixelFormat = .bgra8Unorm
            view.depthStencilPixelFormat = .depth32Float

            setupGestureRecognizers(for: view, with: coordinator)
            return view
        }

        @MainActor
        public func updateUIView(_ uiView: TouchEnabledMTKView, context: Context) {}

        @MainActor
        public func makeCoordinator() -> ViewportCoordinator {
            return coordinator
        }

        @MainActor
        private func setupGestureRecognizers(
            for view: UIView, with coordinator: ViewportCoordinator
        ) {
            // Pan gesture for dragging
            let panGesture = UIPanGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handlePanGesture(_:)))
            panGesture.delegate = coordinator
            panGesture.maximumNumberOfTouches = 1
            view.addGestureRecognizer(panGesture)

            // Pinch gesture for zooming/scaling
            let pinchGesture = UIPinchGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handlePinchGesture(_:)))
            pinchGesture.delegate = coordinator
            view.addGestureRecognizer(pinchGesture)

            // Rotation gesture
            let rotationGesture = UIRotationGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleRotationGesture(_:)))
            rotationGesture.delegate = coordinator
            view.addGestureRecognizer(rotationGesture)

            // Swipe gestures
            let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
            for direction in directions {
                let swipeGesture = UISwipeGestureRecognizer(
                    target: coordinator,
                    action: #selector(ViewportCoordinator.handleSwipeGesture(_:)))
                swipeGesture.direction = direction
                view.addGestureRecognizer(swipeGesture)
            }

            // Long press gesture
            let longPressGesture = UILongPressGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleLongPressGesture(_:)))
            longPressGesture.minimumPressDuration = 0.5
            view.addGestureRecognizer(longPressGesture)

            // Tap gesture
            let tapGesture = UITapGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleTapGesture(_:)))
            tapGesture.numberOfTapsRequired = 1
            view.addGestureRecognizer(tapGesture)

            // Double tap gesture
            let doubleTapGesture = UITapGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleDoubleTapGesture(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            tapGesture.require(toFail: doubleTapGesture)
            view.addGestureRecognizer(doubleTapGesture)
        }
    }

    @MainActor
    public class TouchEnabledMTKView: MTKView {
        weak var touchDelegate: TouchEventDelegate?

        override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchDelegate?.touchesBegan(touches, with: event, in: self)
            super.touchesBegan(touches, with: event)
        }

        override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchDelegate?.touchesMoved(touches, with: event, in: self)
            super.touchesMoved(touches, with: event)
        }

        override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchDelegate?.touchesEnded(touches, with: event, in: self)
            super.touchesEnded(touches, with: event)
        }

        override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchDelegate?.touchesCancelled(touches, with: event, in: self)
            super.touchesCancelled(touches, with: event)
        }
    }
#else
    import AppKit

    public struct ViewportView: NSViewRepresentable {
        private let coordinator: ViewportCoordinator

        public init(coordinator: ViewportCoordinator) {
            self.coordinator = coordinator
        }

        @MainActor
        public func makeNSView(context: Context) -> MouseEnabledMTKView {
            let view = MouseEnabledMTKView()

            //NOTE: Setup Metal device and view properties
            if let device = MTLCreateSystemDefaultDevice() {
                view.device = device
            }

            view.delegate = coordinator
            view.mouseDelegate = coordinator
            view.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
            view.preferredFramesPerSecond = 60
            view.isPaused = false
            view.enableSetNeedsDisplay = false
            view.colorPixelFormat = .bgra8Unorm
            view.depthStencilPixelFormat = .depth32Float

            setupGestureRecognizers(for: view, with: coordinator)
            return view
        }

        @MainActor
        public func updateNSView(_ nsView: MouseEnabledMTKView, context: Context) {}

        @MainActor
        public func makeCoordinator() -> ViewportCoordinator {
            return coordinator
        }

        @MainActor
        private func setupGestureRecognizers(
            for view: NSView, with coordinator: ViewportCoordinator
        ) {
            let magnificationGesture = NSMagnificationGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleMagnificationGesture(_:)))
            view.addGestureRecognizer(magnificationGesture)

            let rotationGesture = NSRotationGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleRotationGesture(_:)))
            view.addGestureRecognizer(rotationGesture)

            let panGesture = NSPanGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handlePanGesture(_:)))
            view.addGestureRecognizer(panGesture)

            let clickGesture = NSClickGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleClickGesture(_:)))
            view.addGestureRecognizer(clickGesture)
        }
    }

    @MainActor
    public class MouseEnabledMTKView: MTKView {
        weak var mouseDelegate: MouseEventDelegate?

        override public var acceptsFirstResponder: Bool { return true }

        override public func mouseDown(with event: NSEvent) {
            mouseDelegate?.mouseDown(with: event, in: self)
            super.mouseDown(with: event)
        }

        override public func mouseDragged(with event: NSEvent) {
            mouseDelegate?.mouseDragged(with: event, in: self)
            super.mouseDragged(with: event)
        }

        override public func mouseUp(with event: NSEvent) {
            mouseDelegate?.mouseUp(with: event, in: self)
            super.mouseUp(with: event)
        }

        override public func rightMouseDown(with event: NSEvent) {
            mouseDelegate?.rightMouseDown(with: event, in: self)
            super.rightMouseDown(with: event)
        }

        override public func rightMouseDragged(with event: NSEvent) {
            mouseDelegate?.rightMouseDragged(with: event, in: self)
            super.rightMouseDragged(with: event)
        }

        override public func rightMouseUp(with event: NSEvent) {
            mouseDelegate?.rightMouseUp(with: event, in: self)
            super.rightMouseUp(with: event)
        }

        override public func scrollWheel(with event: NSEvent) {
            mouseDelegate?.scrollWheel(with: event, in: self)
            super.scrollWheel(with: event)
        }

        override public func keyDown(with event: NSEvent) {
            mouseDelegate?.keyEvent(with: event, in: self, isDown: true)
            super.keyDown(with: event)
        }

        override public func keyUp(with event: NSEvent) {
            mouseDelegate?.keyEvent(with: event, in: self, isDown: false)
            super.keyUp(with: event)
        }

        override public func flagsChanged(with event: NSEvent) {
            mouseDelegate?.flagsChanged(with: event, in: self)
            super.flagsChanged(with: event)
        }
    }
#endif

