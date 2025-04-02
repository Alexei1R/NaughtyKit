// Copyright (c) 2025 The Noughy Fox
// https://opensource.org/licenses/MIT

import MetalKit

@MainActor
public class ViewportRenderer {
    private weak var viewport: Viewport?

    public init(viewport: Viewport) {
        self.viewport = viewport
    }

    public func start(view: MTKView) {
        viewport?.delegate?.start(viewport!, view)
    }

    public func draw(in view: MTKView) {
        if let viewport = viewport {
            viewport.delegate?.draw(viewport, view)
        } else {
            defaultDraw(in: view)
        }
    }

    public func resize(to size: CGSize) {
        if let viewport = viewport {
            viewport.delegate?.resize(
                viewport, to: vec2f(x: Float(size.width), y: Float(size.height)))
        }
    }

    private func defaultDraw(in view: MTKView) {
        guard let device = view.device,
              let commandQueue = device.makeCommandQueue(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
