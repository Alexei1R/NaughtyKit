// Copyright (c) 2025 The Noughy Fox
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
import Foundation

public enum EventType: Hashable {
    case touch
    case key
    case mouse
    case window
    case gesture
    case custom(String)

    var name: String {
        switch self {
        case .touch: return "TouchEvent"
        case .key: return "KeyEvent"
        case .mouse: return "MouseEvent"
        case .window: return "WindowEvent"
        case .gesture: return "GestureEvent"
        case .custom(let name): return name
        }
    }
}

public protocol EventProtocol {
    static var eventType: EventType { get }
    var type: EventType { get }
}

//NOTE: In case the event type is not defined in the event itself
extension EventProtocol {
    public var type: EventType {
        return Self.eventType
    }
}

public final class Events: Module {
    private var handlers: [EventType: [(id: Int, handler: (Any) -> Void)]] = [:]
    private var nextId = 0

    public init() {}

    @discardableResult
    public func subscribe<T: EventProtocol>(to eventType: T.Type, handler: @escaping (T) -> Void)
        -> Int
    {
        let type = eventType.eventType
        let id = nextId
        nextId += 1

        let wrappedHandler: (Any) -> Void = { event in
            guard let typedEvent = event as? T else { return }
            handler(typedEvent)
        }

        if handlers[type] == nil {
            handlers[type] = []
        }

        handlers[type]?.append((id: id, handler: wrappedHandler))

        return id
    }

    public func unsubscribe(_ id: Int) {
        for type in handlers.keys {
            handlers[type] = handlers[type]?.filter { $0.id != id }
        }
    }

    public func publish<T: EventProtocol>(_ event: T) {
        guard let eventHandlers = handlers[event.type] else { return }

        for (_, handler) in eventHandlers {
            handler(event)
        }
    }
}
