// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Transform
public class Transform {
    public var position: vec3f
    public var rotation: vec3f
    public var scale: vec3f

    public init(
        position: vec3f = vec3f(0, 0, 0),
        rotation: vec3f = vec3f(0, 0, 0),
        scale: vec3f = vec3f(1, 1, 1)
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}
