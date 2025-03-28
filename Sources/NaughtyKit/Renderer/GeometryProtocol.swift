// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

public protocol RenderableGeometry {
    var entity: Entity { get }
    var isVisibile: Bool { get set }
    var transform: Transform { get set }
    var material: Material { get set }

}

//NOTE: Selectable Geometry
public struct SelectableVertex {
    //NOTE: First 1f is the entity ID
    //NOTE: Rest is the vertex index in the mesh
    var entity: UInt32
    var vertexIndex: UInt32
    var position: vec3f

    init(entity: UInt32, vertexIndex: UInt32, position: vec3f) {
        self.entity = entity
        self.vertexIndex = vertexIndex
        self.position = position
    }

}

public protocol SelectableGeometry {
    // Functions to get the selectable vertex buffer
    func getSelectableVertexBuffer() -> [SelectableVertex]

}

//NOTE: Editable Geometry
public protocol EditableGeometry {
    func addVertex<T>(vertex: T, at position: vec3f)
    func removeVertex(at index: Int)
    func moveVertex(index: Int, to position: vec3f)
    func getVertex(at index: Int) -> vec3f?
}
