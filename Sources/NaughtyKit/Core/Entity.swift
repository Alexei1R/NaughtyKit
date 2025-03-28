// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation

// NOTE: Base component protocol
public protocol Component: Any {}

// NOTE: Core entity identifier
public struct Entity: Hashable {
    public let id: UInt32

    private init(id: UInt32) {
        self.id = id
    }

    @inline(__always)
    public static func generate() -> Entity {
        let uuid = UUID().uuid
        let id = UInt32(uuid.0) ^ UInt32(uuid.1) ^ UInt32(uuid.2) ^ UInt32(uuid.3)
        return Entity(id: id)
    }
}
