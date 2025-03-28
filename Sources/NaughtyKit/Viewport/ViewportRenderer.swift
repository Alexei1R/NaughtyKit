// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import MetalKit

// NOTE: - Metal Rendering Implementation
@MainActor
public class ViewportRenderer {
    public init() {
        print("ViewportRenderer initialized")
    }
    
    public func draw(in view: MTKView) {
        guard let device = view.device,
              let commandQueue = device.makeCommandQueue(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable
        else {
            return
        }

        // Create command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        // Create render command encoder using the render pass descriptor
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor) else { return }

        // End encoding
        renderEncoder.endEncoding()

        // Present drawable and commit command buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    public func resize(to size: CGSize) {
        // Handle resize events if needed
    }
}
