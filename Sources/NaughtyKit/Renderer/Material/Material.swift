// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation
import simd

//NOTE: Defines the types of parameters that can be stored in a material
public enum MaterialParamType {
    case float
    case float2
    case float3
    case float4
    case matrix4x4
    case integer
    case boolean

    var size: Int {
        switch self {
        case .float: return MemoryLayout<Float>.size
        case .float2: return MemoryLayout<vec2f>.size
        case .float3: return MemoryLayout<vec3f>.size
        case .float4: return MemoryLayout<vec4f>.size
        case .matrix4x4: return MemoryLayout<mat4f>.size
        case .integer: return MemoryLayout<Int32>.size
        case .boolean: return MemoryLayout<UInt32>.size
        }
    }

    var alignment: Int {
        switch self {
        case .float: return MemoryLayout<Float>.alignment
        case .float2: return MemoryLayout<vec2f>.alignment
        case .float3: return MemoryLayout<vec3f>.alignment
        case .float4: return MemoryLayout<vec4f>.alignment
        case .matrix4x4: return MemoryLayout<mat4f>.alignment
        case .integer: return MemoryLayout<Int32>.alignment
        case .boolean: return MemoryLayout<UInt32>.alignment
        }
    }
}

//NOTE: Stores metadata and value for a single material parameter
public struct MaterialParameter {
    var type: MaterialParamType
    var offset: Int
    var value: Any
}

public class Material {
    public var name: String
    private var parameters: [String: MaterialParameter] = [:]
    private var parameterOrder: [String] = []
    private var isChanged: Bool = true
    private var bufferSize: Int = 0

    public init(name: String = "UnnamedMaterial") {
        self.name = name
    }

    // MARK: - Parameter Setters

    @discardableResult
    public func setFloat(_ name: String, _ value: Float) -> Material {
        setParameter(name, .float, value)
        return self
    }

    @discardableResult
    public func setFloat2(_ name: String, _ value: vec2f) -> Material {
        setParameter(name, .float2, value)
        return self
    }

    @discardableResult
    public func setFloat3(_ name: String, _ value: vec3f) -> Material {
        setParameter(name, .float3, value)
        return self
    }

    @discardableResult
    public func setFloat4(_ name: String, _ value: vec4f) -> Material {
        setParameter(name, .float4, value)
        return self
    }

    @discardableResult
    public func setMatrix4x4(_ name: String, _ value: mat4f) -> Material {
        setParameter(name, .matrix4x4, value)
        return self
    }

    @discardableResult
    public func setInteger(_ name: String, _ value: Int) -> Material {
        setParameter(name, .integer, Int32(value))
        return self
    }

    @discardableResult
    public func setBoolean(_ name: String, _ value: Bool) -> Material {
        setParameter(name, .boolean, value ? UInt32(1) : UInt32(0))
        return self
    }

    // MARK: - Parameter Management

    private func setParameter(_ name: String, _ type: MaterialParamType, _ value: Any) {
        if parameters[name] == nil {
            parameterOrder.append(name)
            parameters[name] = MaterialParameter(type: type, offset: 0, value: value)
            recalculateLayout()
        } else {
            parameters[name]?.value = value
        }
        isChanged = true
    }

    public func getParameter(_ name: String) -> Any? {
        return parameters[name]?.value
    }

    public func getFloat(_ name: String) -> Float? {
        guard let param = parameters[name], param.type == .float else { return nil }
        return param.value as? Float
    }

    public func getFloat2(_ name: String) -> vec2f? {
        guard let param = parameters[name], param.type == .float2 else { return nil }
        return param.value as? vec2f
    }

    public func getFloat3(_ name: String) -> vec3f? {
        guard let param = parameters[name], param.type == .float3 else { return nil }
        return param.value as? vec3f
    }

    public func getFloat4(_ name: String) -> vec4f? {
        guard let param = parameters[name], param.type == .float4 else { return nil }
        return param.value as? vec4f
    }

    public func getMatrix4x4(_ name: String) -> mat4f? {
        guard let param = parameters[name], param.type == .matrix4x4 else { return nil }
        return param.value as? mat4f
    }

    public func getInteger(_ name: String) -> Int32? {
        guard let param = parameters[name], param.type == .integer else { return nil }
        return param.value as? Int32
    }

    public func getBoolean(_ name: String) -> Bool? {
        guard let param = parameters[name], param.type == .boolean else { return nil }
        if let value = param.value as? UInt32 {
            return value != 0
        }
        return nil
    }

    public func removeParameter(_ name: String) {
        guard parameters[name] != nil else { return }

        parameters.removeValue(forKey: name)
        if let index = parameterOrder.firstIndex(of: name) {
            parameterOrder.remove(at: index)
        }

        recalculateLayout()
        isChanged = true
    }

    // MARK: - Buffer Management

    private func recalculateLayout() {
        var currentOffset = 0

        for name in parameterOrder {
            guard let param = parameters[name] else { continue }

            // Align the offset properly for GPU buffer requirements
            let alignment = param.type.alignment
            currentOffset = (currentOffset + alignment - 1) & ~(alignment - 1)

            parameters[name] = MaterialParameter(
                type: param.type,
                offset: currentOffset,
                value: param.value
            )

            currentOffset += param.type.size
        }

        bufferSize = currentOffset
    }

    public func getBufferSize() -> Int {
        return bufferSize
    }

    public func writeToBuffer() -> Data {
        var buffer = Data(count: bufferSize)

        for name in parameterOrder {
            guard let param = parameters[name] else { continue }
            let offset = param.offset

            switch param.type {
            case .float:
                if let value = param.value as? Float {
                    buffer.withUnsafeMutableBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else { return }
                        let pointer = baseAddress.advanced(by: offset).assumingMemoryBound(
                            to: Float.self)
                        pointer.pointee = value
                    }
                }
            case .float2:
                if let value = param.value as? vec2f {
                    buffer.withUnsafeMutableBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else { return }
                        let pointer = baseAddress.advanced(by: offset).assumingMemoryBound(
                            to: vec2f.self)
                        pointer.pointee = value
                    }
                }
            case .float3:
                if let value = param.value as? vec3f {
                    buffer.withUnsafeMutableBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else { return }
                        let pointer = baseAddress.advanced(by: offset).assumingMemoryBound(
                            to: vec3f.self)
                        pointer.pointee = value
                    }
                }
            case .float4:
                if let value = param.value as? vec4f {
                    buffer.withUnsafeMutableBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else { return }
                        let pointer = baseAddress.advanced(by: offset).assumingMemoryBound(
                            to: vec4f.self)
                        pointer.pointee = value
                    }
                }
            case .matrix4x4:
                if let value = param.value as? mat4f {
                    buffer.withUnsafeMutableBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else { return }
                        let pointer = baseAddress.advanced(by: offset).assumingMemoryBound(
                            to: mat4f.self)
                        pointer.pointee = value
                    }
                }
            case .integer:
                if let value = param.value as? Int32 {
                    buffer.withUnsafeMutableBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else { return }
                        let pointer = baseAddress.advanced(by: offset).assumingMemoryBound(
                            to: Int32.self)
                        pointer.pointee = value
                    }
                }
            case .boolean:
                if let value = param.value as? UInt32 {
                    buffer.withUnsafeMutableBytes { ptr in
                        guard let baseAddress = ptr.baseAddress else { return }
                        let pointer = baseAddress.advanced(by: offset).assumingMemoryBound(
                            to: UInt32.self)
                        pointer.pointee = value
                    }
                }
            }
        }

        return buffer
    }

    public func hasChanged() -> Bool {
        return isChanged
    }

    public func markChanged() {
        isChanged = true
    }

    public func markUnchanged() {
        isChanged = false
    }

    public func getParameterNames() -> [String] {
        return parameterOrder
    }
}

