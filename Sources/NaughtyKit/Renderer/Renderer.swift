//
// // Copyright (c) 2025 The Noughy Fox
// //
// // This software is released under the MIT License.
// // https://opensource.org/licenses/MIT
//
// import Metal
// //NOTE: Defined elsewhere , just for reference
// // public struct Entity: Hashable {
// //     public let id: UInt32
// //
// //     private init(id: UInt32) {
// //         self.id = id
// //     }
// //
// //     @inline(__always)
// //     public static func generate() -> Entity {
// //         let uuid = UUID().uuid
// //         let id = UInt32(uuid.0) ^ UInt32(uuid.1) ^ UInt32(uuid.2) ^ UInt32(uuid.3)
// //         return Entity(id: id)
// //     }
// // }
//
// struct SelectableVertex {
//
//     //NOTE: First 1f is the entity ID
//     //NOTE: Rest is the vertex index in the mesh
//     var position: vec4f
// }
//
// public protocol Selectable {
//     //Get the selectable vertex buffer
//     var selectableVertexBuffer: MTLBuffer { get }
//
//
//
// }
//
// // struct Material {
// // }
// //
// private protocol RendereableMaterial  {
// }
//
//
// class RenderGraph {
//     struct RenderPass {
//         var name: String
//         var executeBlock: (MTLCommandBuffer) -> Void
//     }
//
//     var passes: [RenderPass] = []
//
//     func addPass(name: String, executeBlock: @escaping (MTLCommandBuffer) -> Void) {
//         passes.append(RenderPass(name: name, executeBlock: executeBlock))
//     }
//
//     func execute(commandBuffer: MTLCommandBuffer) {
//         for pass in passes {
//             pass.executeBlock(commandBuffer)
//         }
//     }
// }
//
// struct GeometryVertex {
//     var position: vec3f
//     var normal: vec3f
//     var texCoord: vec2f
// }
// struct MeshVertex {
//     var position: vec3f
//     var normal: vec3f
//     var texCoord: vec2f
// }
//
// struct AnimatedMeshVertex {
//     var position: vec3f
//     var normal: vec3f
//     var texCoord: vec2f
//     var boneIndices: vec4i
//     var boneWeights: vec4f
// }
//
// struct CustomAnimatedMeshVertex {
//     var position: vec3f
//     var normal: vec3f
//     var texCoord: vec2f
//     var boneIndices: vec4i
//     var boneWeights: vec4f
//     var customData: vec4f
// }
// //NOTE: Pipeline
// public protocol RenderPipeline {
// }
//
// public final class Pipeline: RenderPipeline, Hashable {
//     public init() {
//         // Initialize the pipeline
//     }
//
// }
//
// //NOTE: Geometry
// // public protocol RenderableGeometry {
// //     public var vertexBuffer
// // }
// //
// public final class GeometryBatcher {
//     private var geometry: [Pipeline: RenderableGeometry] = [:]
//
//     public init() {
//         // Initialize the geometry batcher
//     }
//
//     //NOTE: Templated function to add geometry to the batcher
//     public func addGeometry<T: RenderableGeometry>(_ geometry: T, pipeline: Pipeline) {
//
//     }
// }
//
// enum MeshType{
//     case static
//     case dynamic
//     case stream
// }
//
// public final MeshBatcher {
//     //dependic on type , the mesh batcher will have different types of meshes
//     private var meshes: [Pipeline: Mesh] = [:]
//
//     //depending on the type of mesh , the pipeline will be different , will be batched or not
//
//     public init() {
//         // Initialize the mesh batcher
//     }
//
//     public func addMesh(_ mesh: Mesh, pipeline: Pipeline) {
//         // Add the mesh to the batcher
//     }
//
//     public func removeMesh(_ mesh: Mesh) {
//         // Remove the mesh from the batcher
//     }
//
//     // add adidtional data like animations materials etc if the type of renderable supports it
// }
//
// class PipelineCache {
//     var pipelines: [String: MTLRenderPipelineState] = [:]
//
//     func getPipeline(key: String) -> MTLRenderPipelineState? {
//         return pipelines[key]
//     }
//
//     func createPipeline(key: String, descriptor: MTLRenderPipelineDescriptor, device: MTLDevice)
//         -> MTLRenderPipelineState?
//     {
//         // Create and cache pipeline
//         return nil
//     }
// }
//
//
// public final class Mesh: RenderableGeometry, Selectable , {
//     public var vertexBuffer: MTLBuffer
//
//     public init(path: String , usage: MeshType) {
//         // Initialize the mesh
//     }
//
//
// }
//
// public final class Renderer {
//
//     private let renderPass: RenderGraph
//
//     public init() {
//         renderPass = RenderGraph()
//     }
//
//     public func addRenderPass(name: String, executeBlock: @escaping (MTLCommandBuffer) -> Void) {
//         renderPass.addPass(name: name, executeBlock: executeBlock)
//     }
//
//     public func render(commandBuffer: MTLCommandBuffer) {
//         renderPass.execute(commandBuffer: commandBuffer)
//     }
//
//     public func update() {
//         // Update the renderer
//     }
//
//     public func renderMesh(_ mesh: Mesh, pipeline: Pipeline) {
//         // Render the mesh
//     }
//
//     public func renderGeometryBatcher(_ batcher: GeometryBatcher) {
//         // Render the geometry batcher
//     }
//
//
// }

public final class Renderer {

    init() {

    }

    public func processGeometry(_ geometry: Any) {
        if geometry is RenderableGeometry {
            Log.info("Geometry is renderable")

            if let editableGeometry = geometry as? EditableGeometry {
                Log.info("Geometry is editable")
                _ = editableGeometry.getVertex(at: 0)

            }
        }

        if geometry is SelectableGeometry {
            Log.info("Geometry is selectable")
        }

        if geometry is EditableGeometry {
            Log.info("Geometry is editable")
        }
    }

}
