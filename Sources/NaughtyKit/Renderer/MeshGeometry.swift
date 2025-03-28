// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

public final class MeshGeometry: RenderableGeometry {
    public var entity: Entity
    public var isVisibile: Bool = false
    public var transform: Transform
    public var material: Material = Material()
    public var selectableVertices: [SelectableVertex] = []
    public var vertices: [vec3f] = []

    public init(path: String, entity: Entity, transform: Transform = Transform()) {
        self.entity = entity
        self.transform = transform
    }

    // Another constructor where vertices and indices are specified, templated for the vertex
    public init<T>(
        vertices: [T], indices: [UInt32], entity: Entity, transform: Transform = Transform()
    ) {
        self.entity = entity
        self.transform = transform
        self.vertices = vertices as! [vec3f]
        self.selectableVertices = vertices.enumerated().map {
            SelectableVertex(
                entity: entity.id,
                vertexIndex: UInt32($0.offset),
                position: $0.element as! vec3f
            )
        }
    }

    public func setMaterial(material: Material) {
        self.material = material
    }

    public func setVisibility(isVisible: Bool) {
        self.isVisibile = isVisible
    }

}

//NOTE: Extension for Selectable Geometry Protocol conformance
extension MeshGeometry: SelectableGeometry {
    public func getSelectableVertexBuffer() -> [SelectableVertex] {
        return selectableVertices
    }

}

//NOTE: Extension for Editable Geometry Protocol conformance
extension MeshGeometry: EditableGeometry {

    public func addVertex<T>(vertex: T, at position: vec3f) {
        guard let vertex = vertex as? vec3f else {
            return
        }
        vertices.append(vertex)
        selectableVertices.append(
            SelectableVertex(
                entity: entity.id, vertexIndex: UInt32(vertices.count - 1), position: position))
    }

    public func removeVertex(at index: Int) {
        guard index < vertices.count else {
            return
        }
        vertices.remove(at: index)
        selectableVertices.removeAll { $0.vertexIndex == UInt32(index) }
    }

    public func moveVertex(index: Int, to position: vec3f) {
        guard index < vertices.count else {
            return
        }
        vertices[index] = position
        selectableVertices.removeAll { $0.vertexIndex == UInt32(index) }
        selectableVertices.append(
            SelectableVertex(entity: entity.id, vertexIndex: UInt32(index), position: position))
    }

    public func getVertex(at index: Int) -> vec3f? {
        Log.debug("getVertex(at: \(index))")
        guard index < vertices.count else {
            return nil
        }
        return vertices[index]
    }
}
