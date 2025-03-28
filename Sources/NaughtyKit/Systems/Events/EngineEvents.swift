// Copyright (c) 2025 The Noughy Fox
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation

/// Input button states
public enum ButtonState {
    case pressed
    case released
    case held
}

/// Mouse button identifiers
public enum MouseButton {
    case left
    case right
    case middle
    case other(Int)

    public var rawValue: Int {
        switch self {
        case .left: return 0
        case .right: return 1
        case .middle: return 2
        case .other(let value): return value
        }
    }

    public init(buttonNumber: Int) {
        switch buttonNumber {
        case 0: self = .left
        case 1: self = .right
        case 2: self = .middle
        default: self = .other(buttonNumber)
        }
    }
}

/// Keyboard modifier flags
public struct ModifierKeys: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let shift = ModifierKeys(rawValue: 1 << 0)
    public static let control = ModifierKeys(rawValue: 1 << 1)
    public static let alt = ModifierKeys(rawValue: 1 << 2)
    public static let command = ModifierKeys(rawValue: 1 << 3)
    public static let function = ModifierKeys(rawValue: 1 << 4)
    public static let capsLock = ModifierKeys(rawValue: 1 << 5)
}

/// Mouse event data
public struct MouseEvent: EventProtocol {
    public enum MouseEventType {
        case move
        case buttonDown
        case buttonUp
        case drag
        case scroll
    }

    public let mouseEventType: MouseEventType
    public let position: vec2f
    public let worldPosition: vec3f?
    public let button: MouseButton
    public let modifiers: ModifierKeys
    public let delta: vec2f

    public static var eventType: EventType { return .mouse }

    public init(
        mouseEventType: MouseEventType,
        position: vec2f,
        worldPosition: vec3f? = nil,
        button: MouseButton = .left,
        modifiers: ModifierKeys = [],
        delta: vec2f = .zero
    ) {
        self.mouseEventType = mouseEventType
        self.position = position
        self.worldPosition = worldPosition
        self.button = button
        self.modifiers = modifiers
        self.delta = delta
    }
}

/// Touch event data
public struct TouchEvent: EventProtocol {
    public enum TouchEventType {
        case began
        case moved
        case ended
        case cancelled
    }

    public let touchEventType: TouchEventType
    public let position: vec2f
    public let worldPosition: vec3f?
    public let force: Float
    public let touchId: Int
    public let tapCount: Int
    public let allTouchesCount: Int

    public static var eventType: EventType { return .touch }

    public init(
        touchEventType: TouchEventType,
        position: vec2f,
        worldPosition: vec3f? = nil,
        force: Float = 1.0,
        touchId: Int = 0,
        tapCount: Int = 1,
        allTouchesCount: Int = 1
    ) {
        self.touchEventType = touchEventType
        self.position = position
        self.worldPosition = worldPosition
        self.force = force
        self.touchId = touchId
        self.tapCount = tapCount
        self.allTouchesCount = allTouchesCount
    }
}

/// Keyboard event data
public struct KeyboardEvent: EventProtocol {
    public enum KeyEventType {
        case keyDown
        case keyUp
        case keyRepeat
        case modifierChanged
    }

    public let keyEventType: KeyEventType
    public let keyCode: UInt
    public let character: String?
    public let modifiers: ModifierKeys
    public let isRepeat: Bool

    public static var eventType: EventType { return .key }

    public init(
        keyEventType: KeyEventType,
        keyCode: UInt,
        character: String? = nil,
        modifiers: ModifierKeys = [],
        isRepeat: Bool = false
    ) {
        self.keyEventType = keyEventType
        self.keyCode = keyCode
        self.character = character
        self.modifiers = modifiers
        self.isRepeat = isRepeat
    }
}

/// Gesture event data
public struct GestureEvent: EventProtocol {
    public enum GestureEventType {
        case pan
        case pinch
        case rotate
        case tap
        case longPress
    }

    public enum State {
        case began
        case changed
        case ended
        case cancelled
    }

    public let gestureEventType: GestureEventType
    public let state: State
    public let position: vec2f
    public let translation: vec2f
    public let velocity: vec2f
    public let scale: Float
    public let rotation: Float
    public let modifiers: ModifierKeys
    public let touchCount: Int

    public static var eventType: EventType { return .gesture }

    public init(
        gestureEventType: GestureEventType,
        state: State,
        position: vec2f,
        translation: vec2f = .zero,
        velocity: vec2f = .zero,
        scale: Float = 1.0,
        rotation: Float = 0.0,
        modifiers: ModifierKeys = [],
        touchCount: Int = 1
    ) {
        self.gestureEventType = gestureEventType
        self.state = state
        self.position = position
        self.translation = translation
        self.velocity = velocity
        self.scale = scale
        self.rotation = rotation
        self.modifiers = modifiers
        self.touchCount = touchCount
    }
}
//Touch Events
//implement

/// Window event data (resize, move, etc.)
public struct WindowEvent: EventProtocol {
    public enum WindowEventType {
        case resize
        case move
        case focus
        case unfocus
        case close
    }

    public let windowEventType: WindowEventType
    public let size: vec2f
    public let position: vec2f

    public static var eventType: EventType { return .window }

    public init(
        windowEventType: WindowEventType,
        size: vec2f = .zero,
        position: vec2f = .zero
    ) {
        self.windowEventType = windowEventType
        self.size = size
        self.position = position
    }
}

/// Custom event base for engine-specific events
public protocol CustomEvent: EventProtocol {
    var name: String { get }
}

extension CustomEvent {
    public static var eventType: EventType { return .custom("CustomEvent") }
    public var type: EventType { return .custom(name) }
}
