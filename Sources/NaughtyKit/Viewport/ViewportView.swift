// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Combine
import MetalKit
import SwiftUI

#if os(iOS)
    import UIKit
    // NOTE: - iOS implementation
    public struct ViewportView: UIViewRepresentable {
        public init() {
            print("ViewportView initialized")
        }

        @MainActor
        public func makeUIView(context: Context) -> TouchEnabledMTKView {
            let view = TouchEnabledMTKView()

            if let device = MTLCreateSystemDefaultDevice() {
                view.device = device
            }

            view.delegate = context.coordinator
            view.touchDelegate = context.coordinator
            view.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.0, alpha: 1.0)
            view.preferredFramesPerSecond = 60
            view.isPaused = false
            view.enableSetNeedsDisplay = false
            view.isMultipleTouchEnabled = true
            view.colorPixelFormat = .bgra8Unorm
            view.depthStencilPixelFormat = .depth32Float

            setupGestureRecognizers(for: view, with: context.coordinator)

            return view
        }

        @MainActor
        public func updateUIView(_ uiView: TouchEnabledMTKView, context: Context) {}

        @MainActor
        public func makeCoordinator() -> ViewportCoordinator {
            return ViewportCoordinator()
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

            // Pinch gesture for zooming
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

    // NOTE: - macOS implementation
    public struct ViewportView: NSViewRepresentable {
        public init() {
            print("ViewportView initialized")
        }

        @MainActor
        public func makeNSView(context: Context) -> MouseEnabledMTKView {
            let view = MouseEnabledMTKView()

            if let device = MTLCreateSystemDefaultDevice() {
                view.device = device
            }

            view.delegate = context.coordinator
            view.mouseDelegate = context.coordinator
            view.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
            view.preferredFramesPerSecond = 60
            view.isPaused = false
            view.enableSetNeedsDisplay = false
            view.colorPixelFormat = .bgra8Unorm
            view.depthStencilPixelFormat = .depth32Float

            setupGestureRecognizers(for: view, with: context.coordinator)

            return view
        }

        @MainActor
        public func updateNSView(_ nsView: MouseEnabledMTKView, context: Context) {}

        @MainActor
        public func makeCoordinator() -> ViewportCoordinator {
            return ViewportCoordinator()
        }

        @MainActor
        private func setupGestureRecognizers(
            for view: NSView, with coordinator: ViewportCoordinator
        ) {
            // Setup magnification gesture (pinch)
            let magnificationGesture = NSMagnificationGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleMagnificationGesture(_:)))
            view.addGestureRecognizer(magnificationGesture)

            // Setup rotation gesture
            let rotationGesture = NSRotationGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handleRotationGesture(_:)))
            view.addGestureRecognizer(rotationGesture)

            // Setup pan gesture
            let panGesture = NSPanGestureRecognizer(
                target: coordinator,
                action: #selector(ViewportCoordinator.handlePanGesture(_:)))
            view.addGestureRecognizer(panGesture)
        }
    }

    @MainActor
    public class MouseEnabledMTKView: MTKView {
        weak var mouseDelegate: MouseEventDelegate?

        override public var acceptsFirstResponder: Bool {
            return true
        }

        //NOTE: Mouse Event Handling
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

        //NOTE:  Keyboard Event Handling
        override public func keyDown(with event: NSEvent) {
            mouseDelegate?.keyDown(with: event, in: self)
            super.keyDown(with: event)
        }

        override public func keyUp(with event: NSEvent) {
            mouseDelegate?.keyUp(with: event, in: self)
            super.keyUp(with: event)
        }

        override public func flagsChanged(with event: NSEvent) {
            mouseDelegate?.flagsChanged(with: event, in: self)
            super.flagsChanged(with: event)
        }
    }
#endif
